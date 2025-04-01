import 'package:flutter/material.dart';

class DoctorHomePage extends StatelessWidget {
  final String fullName;
  const DoctorHomePage({super.key, required this.fullName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Welcome Dr, $fullName!',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}