import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';

class SettingsPage extends StatelessWidget {
  final String fullName;
  final String email;

  const SettingsPage({
    super.key,
    this.fullName = 'Hairul Hazwan Ismail',
    this.email = 'hairulhazwan87@gmail.com',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          children: [
            // Profile picture & info
            Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  fullName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(email, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 32),

            // Settings options
            SettingsTile(
              icon: Icons.person_outline,
              title: "Profile Information",
              subtitle: "View and update your personal details",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            SettingsTile(
              icon: Icons.lock_outline,
              title: "Change Password",
              subtitle: "Securely update your account password",
              onTap: () {
                // Navigate to change password screen (to be created)
              },
            ),
            const SizedBox(height: 12),
            SettingsTile(
              icon: Icons.app_registration_outlined,
              title: "Registration",
              subtitle: "Register your aqua farms, ponds and sensors",
              onTap: () {
                // Navigate to registration related page
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
