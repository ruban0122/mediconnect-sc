import 'package:flutter/material.dart';
import 'package:mediconnect/features/DoctorHomePage.dart';
import 'package:mediconnect/features/login/ForgotPasswordScreen.dart';
import 'package:mediconnect/features/main_app_screen.dart';
import 'package:mediconnect/features/registration/auth_service.dart';
import 'package:mediconnect/features/registration/registration_step1.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  String? _error;

  void _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final userData = await authService.loginUser(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _loading = false);

    if (userData != null) {
      final accountType = userData['accountType'] ?? 'patient';

      if (accountType == 'doctor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DoctorHomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePageScreen()),
        );
      }
    } else {
      setState(() => _error = "Invalid email or password");
    }
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
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Login',
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Stack(
                //   alignment: Alignment.center,
                //   children: [
                //     Align(
                //       alignment: Alignment.centerLeft,
                //       child: IconButton(
                //         onPressed: () => Navigator.pop(context),
                //         icon: const Icon(Icons.arrow_back),
                //       ),
                //     ),
                //     const Text(
                //       "Login",
                //       style: TextStyle(
                //         fontSize: 18,
                //         color: Color(0xFF1E3C8D),
                //         fontWeight: FontWeight.w600,
                //       ),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 10),

                // App Logo
                Center(
                  child: Image.asset(
                    'assets/MediConnect Removed.png', // Replace with your actual logo path
                    height: 300,
                    width: 500,
                  ),
                ),

                //const SizedBox(height: 10),
                _buildTextField(
                  controller: _emailController,
                  label: "Email",
                  hint: "Enter your email",
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value!.isEmpty ? "Enter a valid email" : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  label: "Password",
                  hint: "Enter your password",
                  obscureText: true,
                  validator: (value) => value!.length < 6
                      ? "Password must be at least 6 characters"
                      : null,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen()),
                      );
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Color(0xFF1E3C8D),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10), // Space between text and button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3C8D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Login",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RegistrationStep1()),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: "Sign up",
                          style: TextStyle(
                            color: Color(0xFF1E3C8D),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
}
