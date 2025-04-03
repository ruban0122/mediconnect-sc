// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:mediconnect/features/registration/auth_service.dart';
// import 'package:provider/provider.dart';

// import 'features/onboarding/onboarding_screen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(); // 👈 This is mandatory

//   runApp(
//     MultiProvider(
//       providers: [
//         Provider<AuthService>(
//           create: (_) => AuthService(),
//         ),
//       ],
//       child: MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: OnboardingScreen(),
//     );
//   }
// }

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
