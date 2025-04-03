import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SelectDateTimeScreen2 extends StatefulWidget {
  final String doctorId;
  final String appointmentId;
  final String doctorName;
  final String profileImage;
  final String specialization;
  final String location;

  const SelectDateTimeScreen2({
    super.key,
    required this.doctorId,
    required this.appointmentId,
    required this.doctorName,
    required this.profileImage,
    required this.specialization,
    required this.location,
  });

  @override
  State<SelectDateTimeScreen2> createState() => _SelectDateTimeScreen2State();
}

class _SelectDateTimeScreen2State extends State<SelectDateTimeScreen2> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay? selectedTime;
  Set<String> bookedSlots = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchBookedSlots();
  }

  Future<void> _fetchBookedSlots() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: widget.doctorId)
        .where('dateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(
                selectedDate.year, selectedDate.month, selectedDate.day)))
        .where('dateTime',
            isLessThan: Timestamp.fromDate(DateTime(
                selectedDate.year, selectedDate.month, selectedDate.day + 1)))
        .get();

    setState(() {
      bookedSlots = querySnapshot.docs
          .map((doc) => DateFormat('h:mm a')
              .format((doc['dateTime'] as Timestamp).toDate()))
          .toSet();
      selectedTime = null; // Reset time selection when changing date
    });
  }

  Future<void> _confirmReschedule() async {
    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a time slot")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointmentId)
          .update({
        'dateTime': newDateTime,
        'status': 'rescheduled',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context, true); // Return success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to reschedule: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Reschedule Appointment"),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDoctorProfile(),
              const SizedBox(height: 20),
              const Text(
                "Select New Date & Time",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 110, 96, 96)),
              ),
              const SizedBox(height: 10),
              _buildDateSelector(),
              const SizedBox(height: 20),
              const Text("Time",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildTimeSelector(),
              const SizedBox(height: 30),
              _buildConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }

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
              "Dr. ${widget.doctorName}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.specialization,
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              widget.location,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Date",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 14, // 2 weeks availability
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index));
              final isSelected = date.day == selectedDate.day;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDate = date;
                    _fetchBookedSlots();
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2B479A) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2B479A)
                          : Colors.grey.shade300,
                    ),
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
                        DateFormat('MMM d').format(date),
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
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    List<String> availableTimes = [];
    for (int hour = 10; hour < 22; hour++) {
      availableTimes.add(
          "${hour % 12 == 0 ? 12 : hour % 12}:00 ${hour < 12 ? 'AM' : 'PM'}");
      availableTimes.add(
          "${hour % 12 == 0 ? 12 : hour % 12}:30 ${hour < 12 ? 'AM' : 'PM'}");
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: availableTimes.map((time) {
        bool isBooked = bookedSlots.contains(time);
        bool isSelected = selectedTime != null &&
            DateFormat('h:mm a').format(DateTime(
                    0, 0, 0, selectedTime!.hour, selectedTime!.minute)) ==
                time;

        return GestureDetector(
          onTap: isBooked
              ? null
              : () {
                  setState(() {
                    int hour = int.parse(time.split(":")[0]) +
                        (time.contains("PM") && !time.startsWith("12")
                            ? 12
                            : 0);
                    int minute = int.parse(time.split(":")[1].split(" ")[0]);
                    selectedTime = TimeOfDay(hour: hour, minute: minute);
                  });
                },
          child: SizedBox(
            width: 80,
            height: 50,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2B479A)
                    : isBooked
                        ? Colors.grey.shade300
                        : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2B479A)
                        : Colors.grey.shade300),
              ),
              child: Text(time,
                  style: TextStyle(
                      color: isBooked
                          ? Colors.grey
                          : isSelected
                              ? Colors.white
                              : Colors.black,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: selectedTime != null ? _confirmReschedule : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2B479A),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                "Confirm Reschedule",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
