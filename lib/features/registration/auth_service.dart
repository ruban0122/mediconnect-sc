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

//       // Save user profile to Firestore with account type
//       await _firestore.collection('users').doc(userCredential.user!.uid).set({
//         'fullName': fullName,
//         'email': email,
//         'dob': dob,
//         'gender': gender,
//         'accountType': 'patient', // ✅ default role
//         'uid': userCredential.user!.uid,
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       return true;
//     } catch (e) {
//       print("Registration error: $e");
//       return false;
//     }
//   }

//   // Return the full user data instead of just full name
//   Future<Map<String, dynamic>?> loginUser(String email, String password) async {
//     try {
//       final UserCredential userCred = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       final uid = userCred.user!.uid;
//       final userDoc = await _firestore.collection('users').doc(uid).get();
//       return userDoc.data();
//     } catch (e) {
//       print("Login error: $e");
//       return null;
//     }
//   }

//   Future<bool> resetPassword(String email) async {
//     try {
//       await _auth.sendPasswordResetEmail(email: email);
//       return true;
//     } catch (e) {
//       print("Error: $e");
//       return false;
//     }
//   }
// }

//WITHOUT FCM
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class AuthService extends ChangeNotifier {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   User? _user;

//   AuthService() {
//     // Listen for authentication state changes
//     _auth.authStateChanges().listen((User? user) {
//       _user = user;
//       notifyListeners(); // 🔄 Notifies UI when user state changes
//     });
//   }

//   User? get user => _user;

//   Future<bool> registerUser(
//     String email,
//     String password,
//     String fullName,
//     String dob,
//     String gender,
//   ) async {
//     try {
//       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       await _firestore.collection('users').doc(userCredential.user!.uid).set({
//         'fullName': fullName,
//         'email': email,
//         'dob': dob,
//         'gender': gender,
//         'accountType': 'patient', 
//         'uid': userCredential.user!.uid,
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       return true;
//     } catch (e) {
//       print("Registration error: $e");
//       return false;
//     }
//   }

//   Future<Map<String, dynamic>?> loginUser(String email, String password) async {
//     try {
//       final UserCredential userCred = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       final uid = userCred.user!.uid;
//       final userDoc = await _firestore.collection('users').doc(uid).get();
//       return userDoc.data();
//     } catch (e) {
//       print("Login error: $e");
//       return null;
//     }
//   }

//   Future<bool> resetPassword(String email) async {
//     try {
//       await _auth.sendPasswordResetEmail(email: email);
//       return true;
//     } catch (e) {
//       print("Error: $e");
//       return false;
//     }
//   }

//   Future<void> signOut() async {
//     await _auth.signOut();
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  User? _user;

  AuthService() {
    // Listen for authentication state changes
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        await _updateFcmToken(user.uid); // Update token on auth state change
      }
      notifyListeners();
    });

    // Listen for token refresh
    _fcm.onTokenRefresh.listen((newToken) async {
      if (_user != null) {
        await _updateFcmToken(_user!.uid, newToken: newToken);
      }
    });
  }

  User? get user => _user;

  // Helper method to update FCM token
  Future<void> _updateFcmToken(String userId, {String? newToken}) async {
    try {
      final token = newToken ?? await _fcm.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  Future<bool> registerUser(
    String email,
    String password,
    String fullName,
    String dob,
    String gender,
  ) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get FCM token for the new user
      String? fcmToken = await _fcm.getToken();

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'fullName': fullName,
        'email': email,
        'dob': dob,
        'gender': gender,
        'accountType': 'patient', 
        'uid': userCredential.user!.uid,
        'fcmToken': fcmToken, // Add FCM token to user document
        'lastTokenUpdate': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print("Registration error: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      final UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update FCM token on login
      await _updateFcmToken(userCred.user!.uid);

      final uid = userCred.user!.uid;
      final userDoc = await _firestore.collection('users').doc(uid).get();
      return userDoc.data();
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Add this method to handle notification permission request
  Future<void> requestNotificationPermission() async {
    await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }
}
