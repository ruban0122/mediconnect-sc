// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:mediconnect/features/appointment/confirm_appointment_screen.dart';

// class SelectDateTimeScreen extends StatefulWidget {
//   final String doctorId;

//   const SelectDateTimeScreen({super.key, required this.doctorId});

//   @override
//   State<SelectDateTimeScreen> createState() => _SelectDateTimeScreenState();
// }

// class _SelectDateTimeScreenState extends State<SelectDateTimeScreen> {
//   DateTime? selectedDate;
//   TimeOfDay? selectedTime;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Select Date & Time")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 📆 Select Date
//             const Text("Select Date",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             TextButton(
//               onPressed: () async {
//                 DateTime? pickedDate = await showDatePicker(
//                   context: context,
//                   initialDate: DateTime.now(),
//                   firstDate: DateTime.now(),
//                   lastDate: DateTime.now().add(const Duration(days: 30)),
//                 );

//                 if (pickedDate != null) {
//                   setState(() {
//                     selectedDate = pickedDate;
//                   });
//                 }
//               },
//               child: Text(
//                 selectedDate == null
//                     ? "Choose Date"
//                     : DateFormat('yyyy-MM-dd').format(selectedDate!),
//                 style: const TextStyle(fontSize: 16, color: Colors.blue),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // ⏰ Select Time
//             const Text("Select Time",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             TextButton(
//               onPressed: () async {
//                 TimeOfDay? pickedTime = await showTimePicker(
//                   context: context,
//                   initialTime: TimeOfDay.now(),
//                 );

//                 if (pickedTime != null) {
//                   setState(() {
//                     selectedTime = pickedTime;
//                   });
//                 }
//               },
//               child: Text(
//                 selectedTime == null
//                     ? "Choose Time"
//                     : selectedTime!.format(context),
//                 style: const TextStyle(fontSize: 16, color: Colors.blue),
//               ),
//             ),

//             const SizedBox(height: 32),

//             // ✅ Confirm Button
//             Center(
//               child: ElevatedButton(
//                 onPressed: (selectedDate != null && selectedTime != null)
//                     ? () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ConfirmAppointmentScreen(
//                               doctorId: widget.doctorId,
//                               selectedDate: selectedDate!,
//                               selectedTime: selectedTime!,
//                             ),
//                           ),
//                         );
//                       }
//                     : null,
//                 child: const Text("Next"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:mediconnect/features/appointment/confirm_appointment_screen.dart';

// class SelectDateTimeScreen extends StatefulWidget {
//   final String doctorId;
//   final String doctorName;
//   final String specialization;
//   final String location;
//   final String profileImage;

//   const SelectDateTimeScreen({
//     super.key,
//     required this.doctorId,
//     required this.doctorName,
//     required this.specialization,
//     required this.location,
//     required this.profileImage,
//   });

//   @override
//   State<SelectDateTimeScreen> createState() => _SelectDateTimeScreenState();
// }

// class _SelectDateTimeScreenState extends State<SelectDateTimeScreen> {
//   DateTime selectedDate = DateTime.now();
//   TimeOfDay? selectedTime;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text("Book Appointment"),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 🩺 Doctor Profile
//             _buildDoctorProfile(),

//             const SizedBox(height: 20),

//             // 📅 Date Selection
//             const Text(
//               "Book Appointment",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 10),

//             _buildDateSelector(),

//             const SizedBox(height: 20),

//             // ⏰ Time Selection
//             const Text(
//               "Time",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 10),

//             _buildTimeSelector(),

//             const SizedBox(height: 15),

//             // 🛠 Custom Schedule Option
//             _buildCustomScheduleOption(),

//             const Spacer(),

//             // ✅ Confirm Appointment Button
//             _buildConfirmButton(),
//           ],
//         ),
//       ),
//     );
//   }

//   // 🎭 Doctor Profile Widget
//   Widget _buildDoctorProfile() {
//     return Row(
//       children: [
//         CircleAvatar(
//           radius: 40,
//           backgroundImage: NetworkImage(widget.profileImage),
//         ),
//         const SizedBox(width: 15),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               widget.doctorName,
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             Text(widget.specialization, style: const TextStyle(color: Colors.grey)),
//             Row(
//               children: [
//                 const Icon(Icons.location_on, size: 16, color: Colors.blue),
//                 const SizedBox(width: 5),
//                 Text(widget.location, style: const TextStyle(color: Colors.grey)),
//               ],
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   // 📅 Date Selector Widget
//   Widget _buildDateSelector() {
//     return SizedBox(
//       height: 60,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: 7,
//         itemBuilder: (context, index) {
//           DateTime date = DateTime.now().add(Duration(days: index));
//           bool isSelected = date.day == selectedDate.day;

//           return GestureDetector(
//             onTap: () => setState(() => selectedDate = date),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//               margin: const EdgeInsets.only(right: 10),
//               decoration: BoxDecoration(
//                 color: isSelected ? Colors.blue : Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300),
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     DateFormat('E').format(date),
//                     style: TextStyle(
//                       color: isSelected ? Colors.white : Colors.black,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     "${date.day} ${DateFormat('MMM').format(date)}",
//                     style: TextStyle(
//                       color: isSelected ? Colors.white : Colors.black,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ⏰ Time Selector Widget
//   Widget _buildTimeSelector() {
//     List<String> availableTimes = ["7:00 PM", "7:30 PM", "8:00 PM"];
//     return Wrap(
//       spacing: 10,
//       children: availableTimes.map((time) {
//         bool isSelected = selectedTime?.format(context) == time;
//         return GestureDetector(
//           onTap: () {
//             setState(() {
//               selectedTime = TimeOfDay(
//                 hour: int.parse(time.split(":")[0]),
//                 minute: int.parse(time.split(" ")[0].split(":")[1]),
//               );
//             });
//           },
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//             decoration: BoxDecoration(
//               color: isSelected ? Colors.blue : Colors.white,
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300),
//             ),
//             child: Text(
//               time,
//               style: TextStyle(
//                 color: isSelected ? Colors.white : Colors.black,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   // 🛠 Custom Schedule Option
//   Widget _buildCustomScheduleOption() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Text("Want a custom schedule? "),
//         GestureDetector(
//           onTap: () {
//             // Handle custom schedule logic
//           },
//           child: const Text(
//             "Request Schedule",
//             style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
//           ),
//         ),
//       ],
//     );
//   }

//   // ✅ Confirm Button
//   Widget _buildConfirmButton() {
//     return ElevatedButton(
//       onPressed: selectedTime != null
//           ? () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => ConfirmAppointmentScreen(
//                     doctorId: widget.doctorId,
//                     selectedDate: selectedDate,
//                     selectedTime: selectedTime!,
//                   ),
//                 ),
//               );
//             }
//           : null,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: selectedTime != null ? Colors.blue : Colors.grey,
//         minimumSize: const Size(double.infinity, 50),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//       child: const Text(
//         "Make Appointment",
//         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       ),
//     );
//   }
// }

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
              widget.doctorName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(widget.specialization,
                style: const TextStyle(color: Colors.grey)),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.blue),
                const SizedBox(width: 5),
                Text(widget.location,
                    style: const TextStyle(color: Colors.grey)),
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
                color: isSelected ? Colors.blue : Colors.white,
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
    List<String> availableTimes = ["7:00 PM", "7:30 PM", "8:00 PM"];
    return Wrap(
      spacing: 10,
      children: availableTimes.map((time) {
        bool isSelected = selectedTime?.format(context) == time;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedTime = TimeOfDay(
                hour: int.parse(time.split(":")[0]),
                minute: int.parse(time.split(" ")[0].split(":")[1]),
              );
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.shade300),
            ),
            child: Text(
              time,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // // 🛠 Custom Schedule Option
  // Widget _buildCustomScheduleOption() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       const Text("Want a custom schedule? "),
  //       GestureDetector(
  //         onTap: () {
  //           // Handle custom schedule logic
  //         },
  //         child: const Text(
  //           "Request Schedule",
  //           style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
  //         ),
  //       ),
  //     ],
  //   );
  // }

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
                    selectedDate: selectedDate,
                    selectedTime: selectedTime!,
                  ),
                ),
              );
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedTime != null ? Colors.blue : Colors.grey,
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
