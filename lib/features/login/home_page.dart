import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String fullName;
  const HomePage({super.key, required this.fullName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Welcome, $fullName!',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
