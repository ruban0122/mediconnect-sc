import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Assuming you have this
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mediconnect/features/videoCalling/FirestoreService.dart';
import 'package:mediconnect/features/videoCalling/PrescriptionItem.dart';
import 'package:mediconnect/features/videoCalling/appointment_session_complete_screen_doctor.dart'; // Assuming you have this

class PrescriptionScreen extends StatefulWidget {
  final String appointmentId;
  final Duration callDuration;

  const PrescriptionScreen({
    super.key,
    required this.appointmentId,
    required this.callDuration,
  });

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  bool _needsPrescription = true;
  bool _isLoading = false;

  // Use a separate GlobalKey for the main form
  final _mainFormKey = GlobalKey<FormState>();
  // Use a separate GlobalKey for the medication input form
  final _medicationFormKey = GlobalKey<FormState>();

  final TextEditingController _notesController = TextEditingController();
  final List<PrescriptionItem> _medications = [];

  // Form controllers
  final TextEditingController _medNameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  void dispose() {
    _medNameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define a primary color for consistency and modern look
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: const Text(
          'Appointment Summary',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2B479A)),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_medications.isNotEmpty &&
              _needsPrescription) // Only show preview if there are meds and prescription is needed
            IconButton(
              icon: Icon(Icons.visibility_outlined, color: primaryColor),
              tooltip: 'Preview Prescription',
              onPressed: _showPrescriptionPreview,
            ),
        ],
      ),
      body: SafeArea(
        // Use SafeArea to avoid notches/status bar
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _mainFormKey, // Use the main form key here
            child: ListView(
              physics: const BouncingScrollPhysics(), // Smoother scrolling
              children: [
                // _buildCallDuration(primaryColor),
                // const SizedBox(height: 24),
                _buildSectionHeader('Prescription Details'),
                const SizedBox(height: 16),
                _buildPrescriptionToggle(const Color(0xFF2B479A)),
                if (_needsPrescription) ...[
                  const SizedBox(height: 24),
                  _buildSectionHeader('Add Medication'),
                  const SizedBox(height: 16),
                  // Wrap the medication form fields in a new Form with its own key
                  Form(
                    key: _medicationFormKey,
                    child: _buildMedicationForm(primaryColor),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Current Prescription'),
                  const SizedBox(height: 16),
                  _buildMedicationList(),
                ],
                const SizedBox(height: 24),
                _buildSectionHeader('Session Notes'),
                const SizedBox(height: 16),
                _buildSessionNotes(),
                const SizedBox(height: 36),
                _buildSubmitButton(),
                const SizedBox(height: 16), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for consistent section headers
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
      ),
    );
  }

  Widget _buildCallDuration(Color primaryColor) {
    String formatDuration(Duration d) {
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Call Duration',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              formatDuration(widget.callDuration),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionToggle(Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: 1.0), // Adds spacing on both sides
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.2), // Blue glow
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Does the patient need a prescription?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Yes',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  selected: _needsPrescription,
                  selectedColor: primaryColor,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  labelStyle: TextStyle(
                    color: _needsPrescription
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  onSelected: (val) =>
                      setState(() => _needsPrescription = true),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(width: 1),
              Expanded(
                child: ChoiceChip(
                  label: const Text('No',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  selected: !_needsPrescription,
                  selectedColor: primaryColor,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  labelStyle: TextStyle(
                    color: !_needsPrescription
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  onSelected: (val) =>
                      setState(() => _needsPrescription = false),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationForm(Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: 1.0), // Adds spacing on both sides
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3), // Blue glow
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _medNameController,
            decoration: _inputDecoration('Medication Name', Icons.medication),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter medication name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _dosageController,
                  decoration: _inputDecoration('Dosage', Icons.science),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter dosage';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: _quantityController,
                  decoration: _inputDecoration('Qty', Icons.numbers),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter quantity';
                    }
                    if (int.tryParse(value)! <= 0) {
                      return 'Invalid';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _instructionsController,
            decoration: _inputDecoration('Instructions', Icons.description),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter instructions';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add to Prescription'),
              onPressed: _addMedication,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B479A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for consistent input decoration
  InputDecoration _inputDecoration(String labelText, IconData icon) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        // Add error border style
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        // Add focused error border style
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.5),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    );
  }

  Widget _buildMedicationList() {
    if (_medications.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(
            horizontal: 1.0), // Adds spacing on both sides
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(Icons.list_alt, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No medications added yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Use the form above to add medications to this prescription.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Prescribed Medications',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.85),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_medications.length} item(s)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _medications.length,
            itemBuilder: (context, index) {
              final med = _medications[index];
              return Dismissible(
                key: Key('${med.name}_$index'),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red.shade600,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete_forever,
                      color: Colors.white, size: 30),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Delete Medication"),
                      content: Text(
                          "Are you sure you want to remove '${med.name}'?"),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel")),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Delete",
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (_) {
                  _removeMedication(index);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${med.name} removed from list")),
                  );
                },
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        child: Icon(Icons.medication,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      title: Text(
                        med.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text("Dosage: ${med.dosage}",
                              style: const TextStyle(fontSize: 13)),
                          Text("Quantity: ${med.quantity}",
                              style: const TextStyle(fontSize: 13)),
                          if (med.instructions.isNotEmpty)
                            Text("Instructions: ${med.instructions}",
                                style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                      trailing: Icon(Icons.swipe_left,
                          color: Colors.grey.shade400, size: 20),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    if (index < _medications.length - 1)
                      const Divider(height: 1, indent: 20, endIndent: 20),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSessionNotes() {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: 1.0), // Adds spacing on both sides
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3), // Blue glow
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: TextFormField(
          controller: _notesController,
          maxLines: 6,
          decoration: _inputDecoration(
              'Enter your notes about this session...', Icons.notes),
          textAlignVertical: TextAlignVertical.top,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2B479A), // Directly set here
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          elevation: 5, // A bit of shadow
        ),
        onPressed: _isLoading ? null : _submitPrescription,
        child: _isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
            : Text(
                _needsPrescription
                    ? 'Complete with Prescription'
                    : 'Complete Appointment',
              ),
      ),
    );
  }

  void _addMedication() {
    // Validate only the medication form fields using its own key
    if (_medicationFormKey.currentState!.validate()) {
      setState(() {
        _medications.add(
          PrescriptionItem(
            name: _medNameController.text.trim(),
            dosage: _dosageController.text.trim(),
            instructions: _instructionsController.text.trim(),
            quantity: int.tryParse(_quantityController.text.trim()) ?? 1,
          ),
        );
        _clearMedicationForm();
      });
    } else {
      // If validation fails, show a snackbar to inform the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please fill in all medication fields correctly before adding.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _clearMedicationForm() {
    _medNameController.clear();
    _dosageController.clear();
    _instructionsController.clear();
    _quantityController.clear();
    // Reset the validation state for the medication form fields after clearing
    _medicationFormKey.currentState?.reset();
  }

  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }

  void _showPrescriptionPreview() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Prescription Preview',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: _medications.isEmpty
              ? const Text('No medications added for preview.')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Medications (${_medications.length}):',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    ..._medications.map((med) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• ${med.name} (${med.dosage})',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 12.0, top: 4.0),
                                child: Text('Quantity: ${med.quantity}'),
                              ),
                              if (med.instructions.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child:
                                      Text('Instructions: ${med.instructions}'),
                                ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 20),
                    if (_notesController.text.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Session Notes:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(_notesController.text),
                        ],
                      ),
                  ],
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close',
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitPrescription() async {
    // Validate the main form.
    // The medication input fields are now in a separate Form and won't be validated here.
    if (!_mainFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors in the form.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Now, add specific validation for prescription logic
    if (_needsPrescription && _medications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please add at least one medication if a prescription is required.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirestoreService().completeAppointment(
        appointmentId: widget.appointmentId,
        needsPrescription: _needsPrescription,
        medications: _needsPrescription
            ? _medications
            : [], // Pass empty list if no prescription
        notes: _notesController.text,
        duration: widget.callDuration,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AppointmentCompleteScreenDoctor(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error completing appointment: ${e.toString()}')),
        );
        setState(() => _isLoading = false);
      }
    }
  }
}
