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

// import 'package:flutter/material.dart';
// import 'package:mediconnect/features/registration/auth_service.dart';
// import 'package:provider/provider.dart';

// class RegistrationStep2 extends StatefulWidget {
//   final String fullName, email, password;

//   const RegistrationStep2({
//     super.key,
//     required this.fullName,
//     required this.email,
//     required this.password,
//   });

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
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Enter your date of birth")));
//       return;
//     }

//     if (!_isAgreed) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("You must accept the terms")));
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
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Registration failed")));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         centerTitle: true,
//         title: const Text(
//           'Registration',
//           style: TextStyle(
//             color: Color(0xFF2B479A),
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         backgroundColor: Colors.white,
//       ),
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Center(
//                 child: Column(
//                   children: [
//                     Text(
//                       "Almost Done",
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF1E3C8D),
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       "Complete your profile",
//                       style: TextStyle(fontSize: 14, color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 30),
//               _buildTextField(
//                 controller: _dobController,
//                 label: "Date of Birth",
//                 hint: "dd/mm/yyyy",
//                 keyboardType: TextInputType.datetime,
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 "Gender",
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 16,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () => setState(() => _isMale = true),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _isMale
//                             ? const Color(0xFF1E3C8D)
//                             : Colors.grey[300],
//                         foregroundColor: _isMale ? Colors.white : Colors.black,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: const Text("Male"),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () => setState(() => _isMale = false),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: !_isMale
//                             ? const Color(0xFF1E3C8D)
//                             : Colors.grey[300],
//                         foregroundColor: !_isMale ? Colors.white : Colors.black,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: const Text("Female"),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 children: [
//                   Checkbox(
//                     value: _isAgreed,
//                     activeColor: const Color(0xFF1E3C8D),
//                     onChanged: (value) => setState(() => _isAgreed = value!),
//                   ),
//                   const Expanded(
//                     child: Text(
//                       "I agree to the Terms & Conditions",
//                       style: TextStyle(fontSize: 14),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 30),
//               _isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: ElevatedButton(
//                         onPressed: _registerUser,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF1E3C8D),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: const Text(
//                           "Sign Up",
//                           style: TextStyle(fontSize: 16, color: Colors.white),
//                         ),
//                       ),
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     bool obscureText = false,
//     TextInputType keyboardType = TextInputType.text,
//   }) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       keyboardType: keyboardType,
//       decoration: InputDecoration(
//         labelText: label,
//         hintText: hint,
//         filled: true,
//         fillColor: const Color(0xFFF3F6FD),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide.none,
//         ),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final TextEditingController _doctorCodeController = TextEditingController();
  bool _isMale = true;
  bool _isLoading = false;
  bool _isAgreed = false;
  bool _isDoctor = false;

  Future<bool> _validateDoctorCode(String code) async {
    final doc = await FirebaseFirestore.instance
        .collection('doctor_invite_codes')
        .doc(code)
        .get();

    return doc.exists;
  }

  void _registerUser() async {
    if (_dobController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter your date of birth")));
      return;
    }

    if (_isDoctor && _doctorCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Enter the doctor code")));
      return;
    }

    // if (!_isAgreed) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text("You must accept the terms")));
    //   return;
    // }

    if (_isDoctor) {
      bool isValid =
          await _validateDoctorCode(_doctorCodeController.text.trim());
      if (!isValid) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Invalid doctor code")));
        return;
      }
    }

    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    bool success = await authService.registerUser(
      widget.email,
      widget.password,
      widget.fullName,
      _dobController.text.trim(),
      _isMale ? "Male" : "Female",
      accountType: _isDoctor ? "pendingDoctor" : "patient",
    );

    setState(() => _isLoading = false);

    if (success) {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Registration failed")));
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
              const Center(
                child: Column(
                  children: [
                    Text(
                      "Almost Done",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3C8D),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Complete your profile",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Date Of Birth",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _dobController,
                label: "Date of Birth",
                hint: "dd/mm/yyyy",
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 20),
              const Text(
                "Gender",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
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
              // Doctor checkbox
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F6FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CheckboxListTile(
                  title: const Text(
                    "Are you registering as a doctor?",
                    style: TextStyle(fontSize: 14),
                  ),
                  value: _isDoctor,
                  onChanged: (val) => setState(() => _isDoctor = val!),
                  activeColor: const Color(0xFF1E3C8D),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              // Doctor code field
              if (_isDoctor) ...[
                const SizedBox(height: 20),
                const Text(
                  "Enter Your Doctor Code",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _doctorCodeController,
                  label: "Doctor Code",
                  hint: "Enter your doctor invitation code",
                ),
              ],
              const SizedBox(height: 10),
              // Row(
              //   children: [
              //     Checkbox(
              //       value: _isAgreed,
              //       activeColor: const Color(0xFF1E3C8D),
              //       onChanged: (value) => setState(() => _isAgreed = value!),
              //     ),
              //     const Expanded(
              //       child: Text(
              //         "I agree to the Terms & Conditions",
              //         style: TextStyle(fontSize: 14),
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3C8D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(fontSize: 16, color: Colors.white),
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
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
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
