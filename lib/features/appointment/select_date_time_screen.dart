import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediconnect/features/appointment/confirm_appointment_screen.dart';

class SelectDateTimeScreen extends StatefulWidget {
  final String doctorId;

  const SelectDateTimeScreen({super.key, required this.doctorId});

  @override
  State<SelectDateTimeScreen> createState() => _SelectDateTimeScreenState();
}

class _SelectDateTimeScreenState extends State<SelectDateTimeScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Date & Time")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📆 Select Date
            const Text("Select Date",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );

                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
              child: Text(
                selectedDate == null
                    ? "Choose Date"
                    : DateFormat('yyyy-MM-dd').format(selectedDate!),
                style: const TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),

            const SizedBox(height: 16),

            // ⏰ Select Time
            const Text("Select Time",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (pickedTime != null) {
                  setState(() {
                    selectedTime = pickedTime;
                  });
                }
              },
              child: Text(
                selectedTime == null
                    ? "Choose Time"
                    : selectedTime!.format(context),
                style: const TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),

            const SizedBox(height: 32),

            // ✅ Confirm Button
            Center(
              child: ElevatedButton(
                onPressed: (selectedDate != null && selectedTime != null)
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConfirmAppointmentScreen(
                              doctorId: widget.doctorId,
                              selectedDate: selectedDate!,
                              selectedTime: selectedTime!,
                            ),
                          ),
                        );
                      }
                    : null,
                child: const Text("Next"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
