import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class DoctorAvailabilityScreen extends StatefulWidget {
  final String doctorId;

  const DoctorAvailabilityScreen({super.key, required this.doctorId});

  @override
  State<DoctorAvailabilityScreen> createState() =>
      _DoctorAvailabilityScreenState();
}

class _DoctorAvailabilityScreenState extends State<DoctorAvailabilityScreen> {
  TimeOfDay? defaultStartTime;
  TimeOfDay? defaultEndTime;
  DateTime selectedDate = DateTime.now();
  Map<String, List<TimeRange>> exceptions = {};
  Map<String, bool> fullDayUnavailable = {};

  @override
  void initState() {
    super.initState();
    loadAvailability();
  }

  Future<void> loadAvailability() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('doctorAvailability')
          .doc(widget.doctorId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final defaultHours = data['defaultHours'] as Map<String, dynamic>;
        final loadedExceptions =
            data['exceptions'] as Map<String, dynamic>? ?? {};
        final loadedFullDay =
            data['fullDayUnavailable'] as Map<String, dynamic>? ?? {};

        setState(() {
          defaultStartTime = _parseTimeString(defaultHours['start'] as String);
          defaultEndTime = _parseTimeString(defaultHours['end'] as String);

          exceptions = loadedExceptions.map((date, times) => MapEntry(
                date,
                (times as List)
                    .map((time) => TimeRange(
                          start: time['start'] as String,
                          end: time['end'] as String,
                        ))
                    .toList(),
              ));

          fullDayUnavailable = loadedFullDay
              .map((date, unavailable) => MapEntry(date, unavailable as bool));
        });
      } else {
        // Set default working hours if no availability exists
        setState(() {
          defaultStartTime = TimeOfDay(hour: 10, minute: 0);
          defaultEndTime = TimeOfDay(hour: 22, minute: 0);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading availability: ${e.toString()}")),
      );
    }
  }

  TimeOfDay _parseTimeString(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> saveAvailability() async {
    if (defaultStartTime == null || defaultEndTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please set default working hours")),
      );
      return;
    }

    try {
      final formattedStart = _formatTime(defaultStartTime!);
      final formattedEnd = _formatTime(defaultEndTime!);

      await FirebaseFirestore.instance
          .collection('doctorAvailability')
          .doc(widget.doctorId)
          .set({
        'defaultHours': {
          'start': formattedStart,
          'end': formattedEnd,
        },
        'exceptions': exceptions.map((date, ranges) => MapEntry(
              date,
              ranges.map((r) => {'start': r.start, 'end': r.end}).toList(),
            )),
        'fullDayUnavailable': fullDayUnavailable,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Availability updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving availability: ${e.toString()}")),
      );
    }
  }

  String _formatTime(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  void addExceptionTime() async {
    final start = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 12, minute: 0),
    );
    if (start == null) return;

    final end = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: start.hour + 1, minute: start.minute),
    );
    if (end == null) return;

    // Validate time range
    if (end.hour < start.hour ||
        (end.hour == start.hour && end.minute <= start.minute)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("End time must be after start time")),
      );
      return;
    }

    final dateKey = selectedDate.toIso8601String().split('T')[0];
    final newRange = TimeRange(
      start: _formatTime(start),
      end: _formatTime(end),
    );

    setState(() {
      exceptions.update(dateKey, (ranges) => [...ranges, newRange],
          ifAbsent: () => [newRange]);
      fullDayUnavailable
          .remove(dateKey); // Remove full day mark if adding time exception
    });
  }

  void toggleDayAvailability() {
    final dateKey = selectedDate.toIso8601String().split('T')[0];

    setState(() {
      if (fullDayUnavailable[dateKey] ?? false) {
        fullDayUnavailable.remove(dateKey);
        exceptions.remove(dateKey);
      } else {
        fullDayUnavailable[dateKey] = true;
        exceptions.remove(dateKey);
      }
    });
  }

  void removeException(TimeRange range) {
    final dateKey = selectedDate.toIso8601String().split('T')[0];
    setState(() {
      exceptions.update(dateKey, (ranges) {
        final newRanges = ranges.where((r) => r != range).toList();
        if (newRanges.isEmpty) exceptions.remove(dateKey);
        return newRanges;
      }, ifAbsent: () => []);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateKey = selectedDate.toIso8601String().split('T')[0];
    final dayExceptions = exceptions[dateKey] ?? [];
    final isDayUnavailable = fullDayUnavailable[dateKey] ?? false;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Manage Availability',
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
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Set Your Availability",
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF2B479A),
                        fontWeight: FontWeight.bold,
                        fontSize: 16, // Reduced from 18
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Default Hours Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    color: Color(0xFF2B479A),
                                    size: 20), // Reduced from 24
                                const SizedBox(width: 8),
                                Text(
                                  "Default Working Hours",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: const Color(0xFF2B479A),
                                    fontSize: 14, // Reduced from 16
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12), // Reduced from 16
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildTimePickerButton(
                                  context,
                                  isStart: true,
                                  time: defaultStartTime,
                                  label: "Start Time",
                                ),
                                _buildTimePickerButton(
                                  context,
                                  isStart: false,
                                  time: defaultEndTime,
                                  label: "End Time",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12), // Reduced from 15

                    // Exceptions Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    color: Color(0xFF2B479A),
                                    size: 20), // Reduced from 24
                                const SizedBox(width: 8),
                                Text(
                                  "Date Exceptions",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: const Color(0xFF2B479A),
                                    fontSize: 14, // Reduced from 16
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12), // Reduced from 16

                            // Calendar
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: TableCalendar(
                                focusedDay: selectedDate,
                                firstDay: DateTime.now(),
                                lastDay: DateTime.now()
                                    .add(const Duration(days: 365)),
                                calendarStyle: CalendarStyle(
                                  todayDecoration: BoxDecoration(
                                    color: const Color(0xFF2B479A)
                                        .withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  selectedDecoration: const BoxDecoration(
                                    color: Color(0xFF2B479A),
                                    shape: BoxShape.circle,
                                  ),
                                  defaultTextStyle: theme.textTheme.bodySmall ??
                                      const TextStyle(), // Reduced size
                                  weekendTextStyle:
                                      (theme.textTheme.bodySmall ??
                                              const TextStyle())
                                          .copyWith(color: Colors.red),
                                ),
                                headerStyle: HeaderStyle(
                                  formatButtonVisible: false,
                                  titleCentered: true,
                                  titleTextStyle: (theme.textTheme.titleSmall ??
                                          const TextStyle())
                                      .copyWith(color: const Color(0xFF2B479A)),
                                  leftChevronIcon: const Icon(
                                      Icons.chevron_left,
                                      color: Color(0xFF2B479A)),
                                  rightChevronIcon: const Icon(
                                      Icons.chevron_right,
                                      color: Color(0xFF2B479A)),
                                ),
                                selectedDayPredicate: (day) =>
                                    isSameDay(selectedDate, day),
                                onDaySelected: (selectedDay, _) {
                                  setState(() => selectedDate = selectedDay);
                                },
                              ),
                            ),
                            const SizedBox(height: 16), // Kept same for spacing

                            // Day Status Controls
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: toggleDayAvailability,
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                          color: isDayUnavailable
                                              ? Colors.green
                                              : Colors.red),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12), // Reduced
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    child: Text(
                                      isDayUnavailable
                                          ? "Make Day Available"
                                          : "Mark Day Unavailable",
                                      style: TextStyle(
                                        fontSize: 13, // Reduced
                                        color: isDayUnavailable
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8), // Reduced from 10
                                ElevatedButton(
                                  onPressed: addExceptionTime,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2B479A),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12), // Reduced
                                  ),
                                  child: const Text(
                                    "Add Time Block",
                                    style: TextStyle(fontSize: 13), // Reduced
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12), // Reduced from 16

                            // Current Exceptions List
                            if (dayExceptions.isNotEmpty) ...[
                              Text(
                                "Blocked Time Slots:",
                                style: theme.textTheme.titleSmall
                                    ?.copyWith(color: const Color(0xFF2B479A)),
                              ),
                              const SizedBox(height: 6), // Reduced from 8
                              ...dayExceptions
                                  .map((range) => Card(
                                        margin: const EdgeInsets.only(
                                            bottom: 6), // Reduced
                                        elevation: 1,
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 12), // Reduced
                                          leading: const Icon(Icons.block,
                                              color: Colors.red,
                                              size: 20), // Reduced
                                          title: Text(
                                            "${range.start} - ${range.end}",
                                            style: theme
                                                .textTheme.bodySmall, // Smaller
                                          ),
                                          trailing: IconButton(
                                            icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                                size: 20), // Reduced
                                            onPressed: () =>
                                                removeException(range),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ] else if (isDayUnavailable) ...[
                              const SizedBox(height: 12),
                              const Center(
                                child: Text(
                                  "This entire day is marked unavailable",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 13, // Reduced
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24), // Add space before button
                    ElevatedButton(
                      onPressed: saveAvailability,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B479A),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Save Availability",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(
                        height:
                            24), // Add space after button for breathing room
                  ],
                ),
              ),
            ),
          ),

          // // Save Button at Bottom
        ],
      ),
    );
  }

  Widget _buildTimePickerButton(
    BuildContext context, {
    required bool isStart,
    required TimeOfDay? time,
    required String label,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall, // Smaller
        ),
        const SizedBox(height: 4),
        ElevatedButton(
          onPressed: () => _pickTime(isStart),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF2B479A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10), // Reduced
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time, size: 16), // Reduced
              const SizedBox(width: 6), // Reduced
              Text(
                time?.format(context) ?? "Not set",
                style: Theme.of(context).textTheme.bodySmall, // Smaller
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickTime(bool isStartTime) async {
    final current = isStartTime ? defaultStartTime : defaultEndTime;
    final time = await showTimePicker(
      context: context,
      initialTime: current ?? const TimeOfDay(hour: 10, minute: 0),
    );

    if (time != null) {
      setState(() {
        if (isStartTime) {
          defaultStartTime = time;
        } else {
          defaultEndTime = time;
        }
      });
    }
  }
}

class TimeRange {
  final String start;
  final String end;

  TimeRange({required this.start, required this.end});
}
