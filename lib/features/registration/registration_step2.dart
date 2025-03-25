// import 'package:flutter/material.dart';
// import 'package:mediconnect/features/registration/auth_service.dart';
// import 'package:provider/provider.dart';

// class RegistrationStep2 extends StatefulWidget {
//   final String fullName, email, password;

//   const RegistrationStep2({super.key, required this.fullName, required this.email, required this.password});

//   @override
//   State<RegistrationStep2> createState() => _RegistrationStep2State();
// }

// class _RegistrationStep2State extends State<RegistrationStep2> {
//   final TextEditingController _dobController = TextEditingController();
//   bool _isMale = true;
//   bool _isLoading = false;
//   bool _isAgreed = false;

//   void _registerUser() async {
//     if (_dobController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter your date of birth")));
//       return;
//     }

//     if (!_isAgreed) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You must accept the terms")));
//       return;
//     }

//     setState(() => _isLoading = true);

//     final authService = Provider.of<AuthService>(context, listen: false);
//     bool success = await authService.registerUser(
//       widget.email,
//       widget.password,
//       widget.fullName,
//       _dobController.text.trim(),
//       _isMale ? "Male" : "Female",
//     );

//     setState(() => _isLoading = false);

//     if (success) {
//       Navigator.popUntil(context, (route) => route.isFirst);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registration failed")));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Registration - Step 2")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             const Text("Nearly there", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 20),

//             TextFormField(
//               controller: _dobController,
//               decoration: const InputDecoration(labelText: "Date of Birth", border: OutlineInputBorder()),
//               keyboardType: TextInputType.datetime,
//             ),
//             const SizedBox(height: 20),

//             const Text("Gender"),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () => setState(() => _isMale = true),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: _isMale ? Colors.blue : Colors.grey[200],
//                     ),
//                     child: const Text("Male"),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () => setState(() => _isMale = false),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: !_isMale ? Colors.blue : Colors.grey[200],
//                     ),
//                     child: const Text("Female"),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),

//             Row(
//               children: [
//                 Checkbox(value: _isAgreed, onChanged: (value) => setState(() => _isAgreed = value!)),
//                 const Text("Agree to Terms & Conditions"),
//               ],
//             ),
//             const SizedBox(height: 20),

//             _isLoading
//                 ? const CircularProgressIndicator()
//                 : ElevatedButton(
//                     onPressed: _registerUser,
//                     child: const Text("Sign Up"),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:mediconnect/features/registration/auth_service.dart';
import 'package:provider/provider.dart';

class RegistrationStep2 extends StatefulWidget {
  final String fullName, email, password;

  const RegistrationStep2({
    super.key,
    required this.fullName,
    required this.email,
    required this.password,
  });

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter your date of birth")),
      );
      return;
    }

    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must accept the terms")),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Registration',
          style: TextStyle(
            color: Color(0xFF2B479A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row(
              //   children: [
              //     IconButton(
              //       onPressed: () => Navigator.pop(context),
              //       icon: const Icon(Icons.arrow_back),
              //     ),
              //     const Expanded(
              //       child: Center(
              //         child: Text(
              //           "Registration",
              //           style: TextStyle(
              //             fontSize: 18,
              //             color: Color(0xFF1E3C8D),
              //             fontWeight: FontWeight.w600,
              //           ),
              //         ),
              //       ),
              //     ),
              //     const SizedBox(width: 48),
              //   ],
              // ),
              const SizedBox(height: 16),
              const Center(
                child: Column(
                  children: [
                    Text(
                      "Almost There",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3C8D),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Just a few more details",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Date of Birth",
                style: const TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.black),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dobController.text =
                          "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: _dobController,
                    decoration: InputDecoration(
                      hintText: "DD/MM/YYYY",
                      filled: true,
                      fillColor: const Color(0xFFF1F5FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Gender",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _isMale = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isMale
                            ? const Color(0xFF1E3C8D)
                            : Colors.grey[300],
                        foregroundColor: _isMale ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Male"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _isMale = false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !_isMale
                            ? const Color(0xFF1E3C8D)
                            : Colors.grey[300],
                        foregroundColor: !_isMale ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Female"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _isAgreed,
                    onChanged: (value) => setState(() => _isAgreed = value!),
                  ),
                  const Text(" I Agree to Terms & Conditions"),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3C8D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              const TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF1F5FF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
