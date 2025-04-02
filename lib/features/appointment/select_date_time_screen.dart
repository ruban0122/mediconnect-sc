import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediconnect/features/appointment/AppointmentMethodScreen.dart';
import 'package:mediconnect/features/appointment/confirm_appointment_screen.dart';

class SelectDateTimeScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String specialization;
  final String location;
  final String profileImage;

  const SelectDateTimeScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.specialization,
    required this.location,
    required this.profileImage,
  });

  @override
  State<SelectDateTimeScreen> createState() => _SelectDateTimeScreenState();
}

class _SelectDateTimeScreenState extends State<SelectDateTimeScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Book Appointment"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Added SingleChildScrollView here
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🩺 Doctor Profile
              _buildDoctorProfile(),

              const SizedBox(height: 20),

              // 📅 Date Selection
              const Text(
                "Book Appointment",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 110, 96, 96)),
              ),

              const SizedBox(height: 10),
              // 📅 Date Selection
              const Text(
                "Date",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              _buildDateSelector(),

              const SizedBox(height: 20),

              // ⏰ Time Selection
              const Text(
                "Time",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              _buildTimeSelector(),

              const SizedBox(height: 15),

              // 🛠 Custom Schedule Option
              //  _buildCustomScheduleOption(),

              // Removed Spacer() here for better control
              const SizedBox(height: 10),
              // ✅ Confirm Appointment Button
              _buildConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }

  // 🎭 Doctor Profile Widget
  Widget _buildDoctorProfile() {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage(widget.profileImage),
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

  // 📅 Date Selector Widget
  Widget _buildDateSelector() {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder: (context, index) {
          DateTime date = DateTime.now().add(Duration(days: index));
          bool isSelected = date.day == selectedDate.day;

          return GestureDetector(
            onTap: () => setState(() => selectedDate = date),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2B479A) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade300),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${date.day} ${DateFormat('MMM').format(date)}",
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ⏰ Time Selector Widget
  Widget _buildTimeSelector() {
    List<String> availableTimes = [];
    for (int hour = 10; hour < 22; hour++) {
      availableTimes.add(
          "${hour % 12 == 0 ? 12 : hour % 12}:00 ${hour < 12 ? 'AM' : 'PM'}");
      availableTimes.add(
          "${hour % 12 == 0 ? 12 : hour % 12}:30 ${hour < 12 ? 'AM' : 'PM'}");
    }

    return Wrap(
      spacing: 10, // Horizontal space between boxes
      runSpacing: 10, // Vertical space between rows
      children: availableTimes.map((time) {
        List<String> parts = time.split(" ");
        List<String> timeParts = parts[0].split(":");

        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        bool isPM = parts[1] == "PM";

        // Convert to 24-hour format
        if (isPM && hour != 12) hour += 12;
        if (!isPM && hour == 12) hour = 0;

        bool isSelected = selectedTime != null &&
            selectedTime!.hour == hour &&
            selectedTime!.minute == minute;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedTime = TimeOfDay(hour: hour, minute: minute);
            });
          },
          child: SizedBox(
            width: 80, // Ensures uniform width for all boxes
            height: 50, // Ensures uniform height for all boxes
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2B479A) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2B479A)
                        : Colors.grey.shade300),
              ),
              child: Text(
                time,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ✅ Confirm Button
  Widget _buildConfirmButton() {
    return ElevatedButton(
      onPressed: selectedTime != null
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentMethodScreen(
                    doctorId: widget.doctorId,
                    doctorName: widget.doctorName,
                    profileImageUrl: widget.profileImage,
                    specialization: widget.specialization,
                    location: widget.location,
                    selectedDate: selectedDate,
                    selectedTime: selectedTime!,
                  ),
                ),
              );
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedTime != null ? Color(0xFF2B479A) : Colors.grey,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text(
        "Make Appointment",
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
