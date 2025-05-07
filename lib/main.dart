import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mediconnect/features/login/home_page.dart';
import 'package:mediconnect/features/main_app_screen.dart';
import 'package:mediconnect/features/registration/auth_service.dart';
import 'package:mediconnect/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'features/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await NotificationService.initialize();
  await Permission.camera.request();
  await Permission.microphone.request();
  Stripe.publishableKey = 'pk_test_51RLeK7Q68gIi0BHeqhus9oOjzTy47rqxHbPJNBM8g3u3VQF8KVWNKC3BdgaCS3GjfAF2lQJrR9zGXq3U0U5uVNZp00viFxrpka'; // 🔑 Replace with your Stripe public key

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(), // Redirects based on auth state
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (authService.user == null) {
      return const OnboardingScreen(); // 🔄 Show Onboarding/Login if NOT logged in
    } else {
      return const HomePageScreen(); // 🔄 Redirect to ProfilePage if logged in
    }
  }
}
