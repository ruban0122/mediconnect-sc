// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<bool> registerUser(
//     String email,
//     String password,
//     String fullName,
//     String dob,
//     String gender,
//   ) async {
//     try {
//       // Create Firebase Auth user
//       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       // Save additional info to Firestore
//       await _firestore.collection('users').doc(userCredential.user!.uid).set({
//         'fullName': fullName,
//         'email': email,
//         'dob': dob,
//         'gender': gender,
//         'uid': userCredential.user!.uid,
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       return true;
//     } catch (e) {
//       print("Registration error: $e");
//       return false;
//     }
//   }

//   Future<String?> loginUser(String email, String password) async {
//     try {
//       final UserCredential userCred = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       final uid = userCred.user!.uid;
//       final userDoc = await _firestore.collection('users').doc(uid).get();

//       return userDoc.data()?['fullName'] ?? "User";
//     } catch (e) {
//       print("Login error: $e");
//       return null;
//     }
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  

  Future<bool> registerUser(
    String email,
    String password,
    String fullName,
    String dob,
    String gender,
  ) async {
    try {
      // Create Firebase Auth user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user profile to Firestore with account type
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'fullName': fullName,
        'email': email,
        'dob': dob,
        'gender': gender,
        'accountType': 'patient', // ✅ default role
        'uid': userCredential.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print("Registration error: $e");
      return false;
    }
  }

  // Return the full user data instead of just full name
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      final UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCred.user!.uid;
      final userDoc = await _firestore.collection('users').doc(uid).get();
      return userDoc.data();
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  // Future<bool> resetPassword(String email) async {
  //   try {
  //     // Simulate sending a reset password email (replace with Firebase/Auth API)
  //     await Future.delayed(const Duration(seconds: 2));
  //     print("Password reset email sent to $email");
  //     return true; // Simulate success
  //   } catch (e) {
  //     print("Error sending password reset email: $e");
  //     return false; // Simulate failure
  //   }
  // }

  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }
}
