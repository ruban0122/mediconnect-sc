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
  Map<String, dynamic>? doctorAvailability;
  List<String> availableSlots = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    await _fetchDoctorAvailability();
    await _fetchBookedSlots();
    _generateAvailableSlots();
  }

  Future<void> _fetchBookedSlots() async {
    final querySnapshot = await FirebaseFirestore.instance
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
    });
  }

  Future<void> _fetchDoctorAvailability() async {
    final doc = await FirebaseFirestore.instance
        .collection('doctorAvailability')
        .doc(widget.doctorId)
        .get();

    setState(() {
      doctorAvailability = doc.data();
    });
  }

  void _generateAvailableSlots() {
    if (doctorAvailability == null) return;

    final dateKey = selectedDate.toIso8601String().split('T')[0];
    final defaultHours = doctorAvailability!['defaultHours'] as Map<String, dynamic>;
    final exceptions = doctorAvailability!['exceptions'] as Map<String, dynamic>? ?? {};
    final fullDayUnavailable = doctorAvailability!['fullDayUnavailable'] as Map<String, dynamic>? ?? {};

    // Check if day is completely unavailable
    if (fullDayUnavailable[dateKey] == true) {
      setState(() {
        availableSlots = [];
        selectedTime = null;
      });
      return;
    }

    // Get default working hours
    final defaultStart = _parseTimeString(defaultHours['start'] as String);
    final defaultEnd = _parseTimeString(defaultHours['end'] as String);

    // Check for time exceptions for this day
    final dayExceptions = exceptions[dateKey] as List<dynamic>? ?? [];

    // Generate all possible 30-minute slots within working hours
    final slots = <String>[];
    DateTime currentSlot = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      defaultStart.hour,
      defaultStart.minute,
    );

    final endTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      defaultEnd.hour,
      defaultEnd.minute,
    );

    while (currentSlot.isBefore(endTime)) {
      final slotEnd = currentSlot.add(const Duration(minutes: 30));
      
      // Check if this slot falls within any exception time
      bool isAvailable = true;
      
      for (final exception in dayExceptions) {
        final exceptionStart = _parseTimeString(exception['start'] as String);
        final exceptionEnd = _parseTimeString(exception['end'] as String);
        
        final exceptionStartDt = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          exceptionStart.hour,
          exceptionStart.minute,
        );
        
        final exceptionEndDt = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          exceptionEnd.hour,
          exceptionEnd.minute,
        );
        
        if ((currentSlot.isAfter(exceptionStartDt) && currentSlot.isBefore(exceptionEndDt)) ||
            (slotEnd.isAfter(exceptionStartDt) && slotEnd.isBefore(exceptionEndDt)) ||
            (currentSlot.isAtSameMomentAs(exceptionStartDt) && slotEnd.isAtSameMomentAs(exceptionEndDt))) {
          isAvailable = false;
          break;
        }
      }
      
      if (isAvailable) {
        slots.add(DateFormat('h:mm a').format(currentSlot));
      }
      
      currentSlot = currentSlot.add(const Duration(minutes: 30));
    }

    setState(() {
      availableSlots = slots;
    });
  }

  TimeOfDay _parseTimeString(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
// class _SelectDateTimeScreenState extends State<SelectDateTimeScreen> {
//   DateTime selectedDate = DateTime.now();
//   TimeOfDay? selectedTime;
//   Set<String> bookedSlots = {};

//   @override
//   void initState() {
//     super.initState();
//     _fetchBookedSlots();
//   }

//   Future<void> _fetchBookedSlots() async {
//     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//         .collection('appointments')
//         .where('doctorId', isEqualTo: widget.doctorId)
//         .where('dateTime',
//             isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(
//                 selectedDate.year, selectedDate.month, selectedDate.day)))
//         .where('dateTime',
//             isLessThan: Timestamp.fromDate(DateTime(
//                 selectedDate.year, selectedDate.month, selectedDate.day + 1)))
//         .get();

//     setState(() {
//       bookedSlots = querySnapshot.docs
//           .map((doc) => DateFormat('h:mm a')
//               .format((doc['dateTime'] as Timestamp).toDate()))
//           .toSet();
//       selectedTime = null; // Reset time selection when changing date
//     });
//   }

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

  // Update the date selection handler to refresh data
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
            onTap: () async {
              setState(() {
                selectedDate = date;
                selectedTime = null; // Reset time selection when changing date
              });
              await _fetchBookedSlots();
              _generateAvailableSlots();
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
    // Generate all possible 30-minute slots from 10am to 10pm
    List<String> allPossibleSlots = [];
    for (int hour = 10; hour < 22; hour++) {
      allPossibleSlots.add(
          "${hour % 12 == 0 ? 12 : hour % 12}:00 ${hour < 12 ? 'AM' : 'PM'}");
      allPossibleSlots.add(
          "${hour % 12 == 0 ? 12 : hour % 12}:30 ${hour < 12 ? 'AM' : 'PM'}");
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: allPossibleSlots.map((time) {
        // Check if this slot is available (not in exceptions and within working hours)
        bool isAvailable = availableSlots.contains(time);
        
        // Check if this slot is already booked
        bool isBooked = bookedSlots.contains(time);
        
        // Determine if the slot is selectable
        bool isSelectable = isAvailable && !isBooked;
        
        // Check if this slot is currently selected
        bool isSelected = selectedTime != null &&
            DateFormat('h:mm a').format(DateTime(
                    0, 0, 0, selectedTime!.hour, selectedTime!.minute)) ==
                time;

        return GestureDetector(
          onTap: isSelectable
              ? () {
                  setState(() {
                    int hour = int.parse(time.split(":")[0]) +
                        (time.contains("PM") && !time.startsWith("12")
                            ? 12
                            : 0);
                    int minute = int.parse(time.split(":")[1].split(" ")[0]);
                    selectedTime = TimeOfDay(hour: hour, minute: minute);
                  });
                }
              : null,
          child: SizedBox(
            width: 80,
            height: 50,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2B479A)
                    : !isSelectable
                        ? Colors.grey.shade200
                        : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2B479A)
                        : Colors.grey.shade300),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(time,
                      style: TextStyle(
                          color: !isSelectable
                              ? Colors.grey
                              : isSelected
                                  ? Colors.white
                                  : Colors.black,
                          fontWeight: FontWeight.bold)),
                  if (!isSelectable)
                    const Text("Unavailable",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.normal)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }


  //   Widget _buildTimeSelector() {
  //   return Wrap(
  //     spacing: 10,
  //     runSpacing: 10,
  //     children: availableSlots.map((time) {
  //       bool isBooked = bookedSlots.contains(time);
  //       bool isSelected = selectedTime != null &&
  //           DateFormat('h:mm a').format(DateTime(
  //                   0, 0, 0, selectedTime!.hour, selectedTime!.minute)) ==
  //               time;

  //       return GestureDetector(
  //         onTap: isBooked
  //             ? null
  //             : () {
  //                 setState(() {
  //                   int hour = int.parse(time.split(":")[0]) +
  //                       (time.contains("PM") && !time.startsWith("12")
  //                           ? 12
  //                           : 0);
  //                   int minute = int.parse(time.split(":")[1].split(" ")[0]);
  //                   selectedTime = TimeOfDay(hour: hour, minute: minute);
  //                 });
  //               },
  //         child: SizedBox(
  //           width: 80,
  //           height: 50,
  //           child: Container(
  //             alignment: Alignment.center,
  //             decoration: BoxDecoration(
  //               color: isSelected
  //                   ? const Color(0xFF2B479A)
  //                   : isBooked
  //                       ? Colors.grey.shade300
  //                       : Colors.white,
  //               borderRadius: BorderRadius.circular(10),
  //               border: Border.all(
  //                   color: isSelected
  //                       ? const Color(0xFF2B479A)
  //                       : Colors.grey.shade300),
  //             ),
  //             child: Text(time,
  //                 style: TextStyle(
  //                     color: isBooked
  //                         ? Colors.grey
  //                         : isSelected
  //                             ? Colors.white
  //                             : Colors.black,
  //                     fontWeight: FontWeight.bold)),
  //           ),
  //         ),
  //       );
  //     }).toList(),
  //   );
  // }


  // Widget _buildTimeSelector() {
  //   List<String> availableTimes = [];
  //   for (int hour = 10; hour < 22; hour++) {
  //     availableTimes.add(
  //         "${hour % 12 == 0 ? 12 : hour % 12}:00 ${hour < 12 ? 'AM' : 'PM'}");
  //     availableTimes.add(
  //         "${hour % 12 == 0 ? 12 : hour % 12}:30 ${hour < 12 ? 'AM' : 'PM'}");
  //   }

  //   return Wrap(
  //     spacing: 10,
  //     runSpacing: 10,
  //     children: availableTimes.map((time) {
  //       bool isBooked = bookedSlots.contains(time);
  //       bool isSelected = selectedTime != null &&
  //           DateFormat('h:mm a').format(DateTime(
  //                   0, 0, 0, selectedTime!.hour, selectedTime!.minute)) ==
  //               time;

  //       return GestureDetector(
  //         onTap: isBooked
  //             ? null
  //             : () {
  //                 setState(() {
  //                   int hour = int.parse(time.split(":")[0]) +
  //                       (time.contains("PM") && !time.startsWith("12")
  //                           ? 12
  //                           : 0);
  //                   int minute = int.parse(time.split(":")[1].split(" ")[0]);
  //                   selectedTime = TimeOfDay(hour: hour, minute: minute);
  //                 });
  //               },
  //         child: SizedBox(
  //           width: 80,
  //           height: 50,
  //           child: Container(
  //             alignment: Alignment.center,
  //             decoration: BoxDecoration(
  //               color: isSelected
  //                   ? const Color(0xFF2B479A)
  //                   : isBooked
  //                       ? Colors.grey.shade300
  //                       : Colors.white,
  //               borderRadius: BorderRadius.circular(10),
  //               border: Border.all(
  //                   color: isSelected
  //                       ? const Color(0xFF2B479A)
  //                       : Colors.grey.shade300),
  //             ),
  //             child: Text(time,
  //                 style: TextStyle(
  //                     color: isBooked
  //                         ? Colors.grey
  //                         : isSelected
  //                             ? Colors.white
  //                             : Colors.black,
  //                     fontWeight: FontWeight.bold)),
  //           ),
  //         ),
  //       );
  //     }).toList(),
  //   );
  // }

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
