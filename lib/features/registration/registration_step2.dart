import 'package:flutter/material.dart';
import 'package:mediconnect/features/registration/auth_service.dart';
import 'package:provider/provider.dart';

class RegistrationStep2 extends StatefulWidget {
  final String fullName, email, password;

  const RegistrationStep2({super.key, required this.fullName, required this.email, required this.password});

  @override
  State<RegistrationStep2> createState() => _RegistrationStep2State();
}

class _RegistrationStep2State extends State<RegistrationStep2> {
  final TextEditingController _dobController = TextEditingController();
  bool _isMale = true;
  bool _isLoading = false;
  bool _isAgreed = false;

  void _registerUser() async {
    if (_dobController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter your date of birth")));
      return;
    }

    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You must accept the terms")));
      return;
    }

    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    bool success = await authService.registerUser(
      widget.email,
      widget.password,
      widget.fullName,
      _dobController.text.trim(),
      _isMale ? "Male" : "Female",
    );

    setState(() => _isLoading = false);

    if (success) {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registration failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registration - Step 2")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Nearly there", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            TextFormField(
              controller: _dobController,
              decoration: const InputDecoration(labelText: "Date of Birth", border: OutlineInputBorder()),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 20),

            const Text("Gender"),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _isMale = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isMale ? Colors.blue : Colors.grey[200],
                    ),
                    child: const Text("Male"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _isMale = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_isMale ? Colors.blue : Colors.grey[200],
                    ),
                    child: const Text("Female"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Checkbox(value: _isAgreed, onChanged: (value) => setState(() => _isAgreed = value!)),
                const Text("Agree to Terms & Conditions"),
              ],
            ),
            const SizedBox(height: 20),

            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _registerUser,
                    child: const Text("Sign Up"),
                  ),
          ],
        ),
      ),
    );
  }
}

