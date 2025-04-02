import 'package:flutter/material.dart';
import 'package:mediconnect/features/appointment/confirm_appointment_screen.dart';

class AppointmentMethodScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;

  const AppointmentMethodScreen({
    Key? key,
    required this.doctorId,
    required this.doctorName,
    required this.selectedDate,
    required this.selectedTime,
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
      'price': '\RM25',
      'description': 'Chat with Doctor',
      'value': 'messaging',
    },
    {
      'title': 'Video Call',
      'price': '\RM50',
      'description': 'Video call with doctor',
      'value': 'video_call',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Appointment Method'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Package',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text(
              'Select Duration: 30 minutes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            Text(
              'Select Package',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: _methods.length,
                separatorBuilder: (context, index) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final method = _methods[index];
                  return _buildMethodCard(method);
                },
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedMethod == null
                    ? null
                    : () {
                        final selectedMethod = _methods
                            .firstWhere((m) => m['value'] == _selectedMethod);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConfirmAppointmentScreen(
                              doctorId: widget.doctorId,
                              selectedDate: widget.selectedDate,
                              selectedTime: widget.selectedTime,
                              appointmentMethod: _selectedMethod!,
                              appointmentPrice: selectedMethod['price'],
                            ),
                          ),
                        );
                      },
                child: Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodCard(Map<String, dynamic> method) {
    return Card(
      elevation: _selectedMethod == method['value'] ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: _selectedMethod == method['value']
              ? Theme.of(context).primaryColor
              : Colors.grey.shade300,
          width: _selectedMethod == method['value'] ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          setState(() {
            _selectedMethod = method['value'];
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      method['description'],
                      style: TextStyle(
                        color: Colors.grey.shade600,
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
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
