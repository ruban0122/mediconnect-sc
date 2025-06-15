import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mediconnect/features/DoctorHomePage.dart';
import 'package:mediconnect/features/main_app_screen.dart';
import 'package:mediconnect/features/nurse/nurseHome.dart';
import 'package:mediconnect/features/nurse/nurse_home_screen.dart';
import 'package:mediconnect/features/registration/auth_service.dart';
import 'package:mediconnect/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await NotificationService.initialize();
  await Permission.camera.request();
  await Permission.microphone.request();
  Stripe.publishableKey =
      'pk_test_51RLeK7Q68gIi0BHeqhus9oOjzTy47rqxHbPJNBM8g3u3VQF8KVWNKC3BdgaCS3GjfAF2lQJrR9zGXq3U0U5uVNZp00viFxrpka'; // 🔑 Replace with your Stripe public key

  final prefs = await SharedPreferences.getInstance();
  final savedRole = prefs.getString('accountType');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: MyApp(savedRole: savedRole),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? savedRole;
  const MyApp({super.key, required this.savedRole});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(savedRole: savedRole), // Redirects based on auth state
    );
  }
}

// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authService = Provider.of<AuthService>(context);

//     if (authService.user == null) {
//       return const OnboardingScreen(); // 🔄 Show Onboarding/Login if NOT logged in
//     } else {
//       return const HomePageScreen(); // 🔄 Redirect to ProfilePage if logged in
//     }
//   }
// }

// class AuthWrapper extends StatefulWidget {
//   final String? savedRole;
//   const AuthWrapper({super.key, required this.savedRole});

//   @override
//   State<AuthWrapper> createState() => _AuthWrapperState();
// }

// class _AuthWrapperState extends State<AuthWrapper> {
//   String? accountType;
//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadAccountType();
//   }

//   Future<void> _loadAccountType() async {
//     final prefs = await SharedPreferences.getInstance();
//     accountType = prefs.getString('accountType');
//     setState(() {
//       loading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authService = Provider.of<AuthService>(context);

//     if (loading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (authService.user == null) {
//       return const OnboardingScreen();
//     } else {
//       if (savedRole == 'doctor') {
//         return const DocHomePage();
//       } else {
//         return const HomePageScreen();
//       }
//     }
//   }
// }

// class AuthWrapper extends StatelessWidget {
//   final String? savedRole;
//   const AuthWrapper({super.key, required this.savedRole});

//   @override
//   Widget build(BuildContext context) {
//     final authService = Provider.of<AuthService>(context);

//     print('savedRole: $savedRole');

//     if (authService.user == null) {
//       return const OnboardingScreen();
//     } else {
//       if (savedRole == 'doctor') {
//         return const DocHomePage();
//       } else if (savedRole == 'nurse') {
//         return const ClinicAssistantHomePage();
//       } else {
//         return const HomePageScreen();
//       }
//     }
//   }
// }

class AuthWrapper extends StatefulWidget {

  final String? savedRole; // <-- Add this line
  const AuthWrapper({super.key, required this.savedRole});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  String? savedRole;

@override
void initState() {
  super.initState();
  savedRole = widget.savedRole;
  if (savedRole == null) {
    _loadRole();
  }
}


  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedRole = prefs.getString('accountType');
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (authService.user == null) {
      return const OnboardingScreen();
    }

    if (savedRole == null) {
      // Optional: show loading spinner while fetching role
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (savedRole == 'doctor') {
      return const DocHomePage();
    } else if (savedRole == 'nurse') {
      return const ClinicAssistantHomePage();
    } else {
      return const HomePageScreen();
    }
  }
}
