import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mediconnect/features/settingsScreen/change_password_screen.dart';
import '../login/login_screen.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid == null) return;

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Delete Account',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to permanently delete your account? This action is irreversible.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Delete profile image if exists
      try {
        final imageRef =
            FirebaseStorage.instance.ref().child('profile_images/$uid.jpg');
        await imageRef.delete();
      } catch (e) {
        print("No profile image found or failed to delete: $e");
      }

      // Delete user data from Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();

      // Delete user account from FirebaseAuth
      await user!.delete();

      // Sign out the user
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      print('Delete failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete account. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text("Account Settings"),
        centerTitle: true,
        //elevation: 1,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Color(0xFF2B479A),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            // _buildSettingCard(
            //   title: "Privacy & Security",
            //   icon: Icons.lock_outline,
            //   onTap: () {},
            // ),
            // _buildSettingCard(
            //   title: "Notifications",
            //   icon: Icons.notifications_none,
            //   onTap: () {},
            // ),
            _buildSettingCard(
              title: "Change Password",
              icon: Icons.password_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChangePasswordScreen()),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildDeleteAccountCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.2), // Blue glow
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFF2B479A), size: 28),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          trailing:
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountCard() {
    return Card(
      color: Colors.red.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: _deleteAccount,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
        title: const Text(
          "Delete Account",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
        ),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
      ),
    );
  }
}
