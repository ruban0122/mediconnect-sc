import 'package:flutter/material.dart';
import 'package:mediconnect/features/appointment/confirm_appointment_screen.dart';

class AppointmentMethodScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final String profileImageUrl;
  final String location;
  final String specialization;

  const AppointmentMethodScreen({
    Key? key,
    required this.doctorId,
    required this.doctorName,
    required this.selectedDate,
    required this.selectedTime,
    required this.profileImageUrl,
    required this.location,
    required this.specialization,
  }) : super(key: key);

  @override
  _AppointmentMethodScreenState createState() =>
      _AppointmentMethodScreenState();
}

class _AppointmentMethodScreenState extends State<AppointmentMethodScreen> {
  String? _selectedMethod;

  final List<Map<String, dynamic>> _methods = [
    {
      'title': 'Messaging',
      'price': 'RM25',
      'description': 'Chat with Doctor',
      'value': 'messaging',
    },
    {
      'title': 'Video Call',
      'price': 'RM50',
      'description': 'Video call with Doctor',
      'value': 'video_call',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Book Appointment',
          style: TextStyle(
            color: Color(0xFF2B479A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🩺 Doctor Profile (Added)
            _buildDoctorProfile(),

            const SizedBox(height: 20),

            const Text(
              "Select Appointment Method",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 110, 96, 96),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.separated(
                itemCount: _methods.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final method = _methods[index];
                  return _buildMethodCard(method);
                },
              ),
            ),

            const SizedBox(height: 15),

            // ✅ Confirm Button (Styled)
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  // 🎭 Doctor Profile Widget (Added)
  Widget _buildDoctorProfile() {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage(widget.profileImageUrl),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dr " + widget.doctorName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(widget.specialization,
                style:
                    const TextStyle(color: Color.fromARGB(255, 110, 96, 96))),
            Row(
              children: [
                //const Icon(Icons.location_on, size: 16, color: Colors.blue),
                //const SizedBox(width: 5),
                Text(widget.location,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 110, 96, 96))),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // 🎫 Appointment Method Selection Card
  Widget _buildMethodCard(Map<String, dynamic> method) {
    bool isSelected = _selectedMethod == method['value'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method['value'];
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2B479A) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.shade300),
          boxShadow: [
            if (isSelected)
              BoxShadow(color: Colors.blue.shade100, blurRadius: 5)
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method['title'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    method['description'],
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              method['price'],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Confirm Button (Styled)
  Widget _buildConfirmButton() {
    return ElevatedButton(
      onPressed: _selectedMethod == null
          ? null
          : () {
              final selectedMethod =
                  _methods.firstWhere((m) => m['value'] == _selectedMethod);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConfirmAppointmentScreen(
                    doctorName: widget.doctorName,
                    specialization: widget.specialization,
                    location: widget.location,
                    profileImageUrl: widget.profileImageUrl,
                    doctorId: widget.doctorId,
                    selectedDate: widget.selectedDate,
                    selectedTime: widget.selectedTime,
                    appointmentMethod: _selectedMethod!,
                    appointmentPrice: selectedMethod['price'],
                  ),
                ),
              );
            },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _selectedMethod != null ? const Color(0xFF2B479A) : Colors.grey,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text(
        "Confirm Appointment",
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
