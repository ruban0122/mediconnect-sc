// import 'package:flutter/material.dart';
// import 'package:mediconnect/features/login/password_reset_success_screen.dart';
// import 'package:provider/provider.dart';
// import 'package:mediconnect/features/registration/auth_service.dart';

// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});

//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   final _emailController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   bool _loading = false;

//   void _resetPassword() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _loading = true);

//     final authService = Provider.of<AuthService>(context, listen: false);
//     bool success =
//         await authService.resetPassword(_emailController.text.trim());

//     setState(() => _loading = false);

//     if (success) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const PasswordResetSuccessScreen()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Error sending reset link. Try again.")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         // leading: IconButton(
//         //   icon: const Icon(Icons.arrow_back, color: Color(0xFF2B479A)),
//         //   onPressed: () {
//         //     Navigator.pushNamed(context, '/login');
//         //   },
//         // ),
//         centerTitle: true,
//         title: const Text(
//           'Forget Password',
//           style: TextStyle(
//             color: Color(0xFF2B479A),
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         backgroundColor: Colors.white,
//       ),
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Row(
//               //   children: [
//               //     IconButton(
//               //       onPressed: () => Navigator.pop(context),
//               //       icon: const Icon(Icons.arrow_back),
//               //     ),
//               //     const Expanded(
//               //       child: Center(
//               //         child: Text(
//               //           "Registration",
//               //           style: TextStyle(
//               //             fontSize: 18,
//               //             color: Color(0xFF1E3C8D),
//               //             fontWeight: FontWeight.w600,
//               //           ),
//               //         ),
//               //       ),
//               //     ),
//               //     const SizedBox(width: 48),
//               //   ],
//               // ),
//               const SizedBox(height: 16),
//               const Center(
//                 child: Column(
//                   children: [
//                     Text(
//                       "Almost There",
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF1E3C8D),
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       "Just a few more details",
//                       style: TextStyle(fontSize: 14, color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               ),

//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Reset Password",
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 "Enter your email and we'll send a password reset link.",
//                 style: TextStyle(color: Colors.grey),
//               ),
//               const SizedBox(height: 24),
//               TextFormField(
//                 controller: _emailController,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: const InputDecoration(
//                   labelText: "Email",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) =>
//                     value!.isEmpty ? "Enter a valid email" : null,
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: _resetPassword,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF1E3C8D),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: _loading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : const Text(
//                           "Send Reset Link",
//                           style: TextStyle(fontSize: 16, color: Colors.white),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:mediconnect/features/login/password_reset_success_screen.dart';
import 'package:provider/provider.dart';
import 'package:mediconnect/features/registration/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  void _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    bool success =
        await authService.resetPassword(_emailController.text.trim());

    setState(() => _loading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PasswordResetSuccessScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error sending reset link. Try again.")),
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
          'Forget Password',
          style: TextStyle(
            color: Color(0xFF2B479A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey, // ✅ Form is now in the correct place
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Center(
                child: Column(
                  children: [
                    Text(
                      "Reset Password",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3C8D),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Enter your email and we'll send a password reset link.",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              // const Text(
              //   "Reset Password",
              //   style: TextStyle(
              //     fontSize: 22,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // const SizedBox(height: 16),
              // const Text(
              //   "Enter your email and we'll send a password reset link.",
              //   style: TextStyle(color: Colors.grey),
              // ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter a valid email" : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3C8D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Reset Password",
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
}
