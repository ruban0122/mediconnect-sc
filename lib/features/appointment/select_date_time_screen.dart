import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediconnect/features/appointment/AppointmentMethodScreen.dart';

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
  Set<String> bookedSlots = {};

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDoctorProfile(),
              const SizedBox(height: 20),
              const Text("Book Appointment",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 110, 96, 96))),
              const SizedBox(height: 10),
              const Text("Date",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildDateSelector(),
              const SizedBox(height: 20),
              const Text("Time",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildTimeSelector(),
              const SizedBox(height: 15),
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
            radius: 40, backgroundImage: NetworkImage(widget.profileImage)),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Dr " + widget.doctorName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.specialization,
                style:
                    const TextStyle(color: Color.fromARGB(255, 110, 96, 96))),
            Text(widget.location,
                style:
                    const TextStyle(color: Color.fromARGB(255, 110, 96, 96))),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        itemBuilder: (context, index) {
          DateTime date = DateTime.now().add(Duration(days: index));
          bool isSelected = date.day == selectedDate.day;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date;
                _fetchBookedSlots();
              });
            },
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
                  Text(DateFormat('E').format(date),
                      style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold)),
                  Text("${date.day} ${DateFormat('MMM').format(date)}",
                      style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black)),
                ],
              ),
            ),
          );
        },
      ),
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
        backgroundColor:
            selectedTime != null ? const Color(0xFF2B479A) : Colors.grey,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text("Make Appointment",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }
}
