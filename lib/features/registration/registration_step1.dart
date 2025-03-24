// import 'package:flutter/material.dart';
// import 'registration_step2.dart';

// class RegistrationStep1 extends StatefulWidget {
//   const RegistrationStep1({super.key});

//   @override
//   State<RegistrationStep1> createState() => _RegistrationStep1State();
// }

// class _RegistrationStep1State extends State<RegistrationStep1> {
//   final TextEditingController _fullNameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   void _goToNextStep() {
//     if (!_formKey.currentState!.validate()) return;

//     if (_passwordController.text != _confirmPasswordController.text) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
//       return;
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => RegistrationStep2(
//           fullName: _fullNameController.text.trim(),
//           email: _emailController.text.trim(),
//           password: _passwordController.text.trim(),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Registration")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               const Text("New User Registration", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 20),

//               TextFormField(
//                 controller: _fullNameController,
//                 decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
//                 validator: (value) => value!.isEmpty ? "Enter your name" : null,
//               ),
//               const SizedBox(height: 10),

//               TextFormField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
//                 keyboardType: TextInputType.emailAddress,
//                 validator: (value) => value!.isEmpty ? "Enter a valid email" : null,
//               ),
//               const SizedBox(height: 10),

//               TextFormField(
//                 controller: _passwordController,
//                 decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()),
//                 obscureText: true,
//                 validator: (value) => value!.length < 6 ? "Password must be at least 6 characters" : null,
//               ),
//               const SizedBox(height: 10),

//               TextFormField(
//                 controller: _confirmPasswordController,
//                 decoration: const InputDecoration(labelText: "Confirm Password", border: OutlineInputBorder()),
//                 obscureText: true,
//               ),
//               const SizedBox(height: 20),

//               ElevatedButton(
//                 onPressed: _goToNextStep,
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//                 child: const Text("Next", style: TextStyle(color: Colors.white)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'registration_step2.dart';

class RegistrationStep1 extends StatefulWidget {
  const RegistrationStep1({super.key});

  @override
  State<RegistrationStep1> createState() => _RegistrationStep1State();
}

class _RegistrationStep1State extends State<RegistrationStep1> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _goToNextStep() {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistrationStep2(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Registration",
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF1E3C8D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // To balance the row visually
                  ],
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Column(
                    children: [
                      Text(
                        "New User Registration",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3C8D),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Fill in your details.",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildTextField(
                  controller: _fullNameController,
                  label: "Full Name",
                  hint: "Enter as per your ID",
                  validator: (value) =>
                      value!.isEmpty ? "Enter your name" : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: "Email",
                  hint: "Enter email",
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value!.isEmpty ? "Enter a valid email" : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  label: "Password",
                  hint: "Enter Password",
                  obscureText: true,
                  validator: (value) => value!.length < 6
                      ? "Password must be at least 6 characters"
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: "Confirm Password",
                  hint: "Enter Password",
                  obscureText: true,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _goToNextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3C8D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Sign Up",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(
                        context), // Adjust if login screen is separate
                    child: RichText(
                      text: const TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: "Log in",
                            style: TextStyle(
                                color: Color(0xFF1E3C8D),
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF3F6FD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
