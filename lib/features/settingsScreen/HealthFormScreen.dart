import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HealthFormScreen extends StatefulWidget {
  final Map<String, dynamic>? existingData;

  const HealthFormScreen({super.key, this.existingData});

  @override
  State<HealthFormScreen> createState() => _HealthFormScreenState();
}

class _HealthFormScreenState extends State<HealthFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedHeight;
  String? selectedWeight;
  String? selectedBloodType;
  final TextEditingController _chronicController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _medicationsController = TextEditingController();

  // New lists for multiple selections
  List<String> chronicDiseases = [];
  List<String> allergies = [];
  List<String> medications = [];

  // Controllers for text fields
  final TextEditingController _chronicInputController = TextEditingController();
  final TextEditingController _allergiesInputController =
      TextEditingController();
  final TextEditingController _medicationsInputController =
      TextEditingController();

  bool isLoading = false;

  final List<String> heights =
      List.generate(50, (index) => "${140 + index} cm");
  final List<String> weights = List.generate(50, (index) => "${40 + index} kg");
  final List<String> bloodTypes = [
    "A+",
    "A-",
    "B+",
    "B-",
    "AB+",
    "AB-",
    "O+",
    "O-"
  ];
  final List<String> commonChronicDiseases = [
    'Diabetes',
    'Hypertension',
    'Asthma',
    'Arthritis',
    'Heart Disease',
    'Chronic Kidney Disease',
    'COPD',
    'Cancer',
    'HIV/AIDS',
    'Other' // Keep this as an option
  ];

  final List<String> commonAllergies = [
    'Penicillin',
    'Sulfa Drugs',
    'NSAIDs',
    'Latex',
    'Peanuts',
    'Shellfish',
    'Eggs',
    'Dust Mites',
    'Pollen',
    'Other'
  ];

  final List<String> commonMedications = [
    'Insulin',
    'Metformin',
    'Lisinopril',
    'Atorvastatin',
    'Albuterol',
    'Ibuprofen',
    'Paracetamol',
    'Omeprazole',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    if (widget.existingData != null) {
      setState(() {
        selectedHeight = widget.existingData?['height'];
        selectedWeight = widget.existingData?['weight'];
        selectedBloodType = widget.existingData?['bloodType'];

        // Handle chronic diseases (both string and list cases)
        if (widget.existingData?['chronicDiseases'] != null) {
          if (widget.existingData?['chronicDiseases'] is String) {
            chronicDiseases = [widget.existingData?['chronicDiseases']];
          } else {
            chronicDiseases = List<String>.from(
                widget.existingData?['chronicDiseases'] ?? []);
          }
        }

        // Handle allergies (both string and list cases)
        if (widget.existingData?['allergies'] != null) {
          if (widget.existingData?['allergies'] is String) {
            allergies = [widget.existingData?['allergies']];
          } else {
            allergies =
                List<String>.from(widget.existingData?['allergies'] ?? []);
          }
        }

        // Handle medications (both string and list cases)
        if (widget.existingData?['medications'] != null) {
          if (widget.existingData?['medications'] is String) {
            medications = [widget.existingData?['medications']];
          } else {
            medications =
                List<String>.from(widget.existingData?['medications'] ?? []);
          }
        }
      });
    }
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('records')
        .doc('health')
        .set({
      'height': selectedHeight,
      'weight': selectedWeight,
      'bloodType': selectedBloodType,
      'chronicDiseases': chronicDiseases,
      'allergies': allergies,
      'medications': medications,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    setState(() => isLoading = false);
    Navigator.pop(context);
  }

  Widget _buildMultiSelectField({
    required String label,
    required List<String> selectedItems,
    required List<String> options,
    required Function(List<String>) onSelectionChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () async {
            final newSelection = await _showMultiSelectDialog(
              context: context,
              items: options,
              selectedItems: selectedItems,
              title: 'Select $label',
            );
            onSelectionChanged(newSelection);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedItems.isEmpty
                          ? 'Select $label'
                          : '${selectedItems.length} selected',
                      style: TextStyle(
                        color:
                            selectedItems.isEmpty ? Colors.grey : Colors.black,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
                if (selectedItems.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: selectedItems.map((item) {
                      return Chip(
                        label: Text(item),
                        backgroundColor:
                            const Color(0xFF2B479A).withOpacity(0.1),
                        labelStyle: const TextStyle(color: Color(0xFF2B479A)),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<List<String>> _showMultiSelectDialog({
    required BuildContext context,
    required List<String> items,
    required List<String> selectedItems,
    required String title,
  }) async {
    final List<String> tempSelected = List.from(selectedItems);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              children: items.map((item) {
                return CheckboxListTile(
                  title: Text(item),
                  value: tempSelected.contains(item),
                  onChanged: (bool? selected) {
                    if (selected == true) {
                      tempSelected.add(item);
                    } else {
                      tempSelected.remove(item);
                    }
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, tempSelected);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    return tempSelected;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        title: const Text(
          'Medical Information',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2B479A)),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Height, Weight, Blood Type fields remain the same
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Height',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildDropdown(selectedHeight, heights, (val) {
                      setState(() => selectedHeight = val);
                    }),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Weight',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildDropdown(selectedWeight, weights, (val) {
                      setState(() => selectedWeight = val);
                    }),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Blood Type',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildDropdown(selectedBloodType, bloodTypes, (val) {
                      setState(() => selectedBloodType = val);
                    }),
                    const SizedBox(height: 16),

                    // Chronic Diseases
                    _buildMultiSelectField(
                      label: 'Chronic Diseases',
                      selectedItems: chronicDiseases,
                      options: commonChronicDiseases,
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          chronicDiseases = newSelection;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

// Allergies
                    _buildMultiSelectField(
                      label: 'Allergies',
                      selectedItems: allergies,
                      options: commonAllergies,
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          allergies = newSelection;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

// Medications
                    _buildMultiSelectField(
                      label: 'Medications',
                      selectedItems: medications,
                      options: commonMedications,
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          medications = newSelection;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Buttons remain the same
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[600],
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Cancel",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveRecord,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2B479A),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Update",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDropdown(
      String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: const TextStyle(fontSize: 16)),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (val) => val == null ? "Please select a value" : null,
      ),
    );
  }

  Widget _buildProfileField(TextEditingController controller, String hintText) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) => value!.isEmpty ? "Field cannot be empty" : null,
      ),
    );
  }
}
