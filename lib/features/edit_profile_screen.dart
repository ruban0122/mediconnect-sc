import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mediconnect/features/login/login_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _dobController = TextEditingController();
  bool _isMale = true;
  File? _imageFile;
  String? _imageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDocSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final userDoc = userDocSnapshot.data();

    if (userDoc != null) {
      setState(() {
        _fullNameController.text = userDoc['fullName'] ?? '';
        _dobController.text = userDoc['dob'] ?? '';
        _isMale = userDoc['gender'] == 'Male';
        _imageUrl = userDoc.containsKey('profileImageUrl')
            ? userDoc['profileImageUrl']
            : null;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<String?> _uploadImage(File image) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('$uid.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    String? imageUrl = _imageUrl;
    if (_imageFile != null) {
      imageUrl = await _uploadImage(_imageFile!);
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'fullName': _fullNameController.text.trim(),
      'dob': _dobController.text.trim(),
      'gender': _isMale ? 'Male' : 'Female',
      'profileImageUrl': imageUrl,
    });

    Navigator.pop(context);
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid == null) return;

    bool confirmed = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text(
            'Are you sure you want to delete your account permanently?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (!confirmed) return;

    try {
      // 1. Delete profile image
      final imageRef =
          FirebaseStorage.instance.ref().child('profile_images/$uid.jpg');
      await imageRef
          .delete()
          .catchError((_) {}); // Ignore if file doesn't exist

      // 2. Delete user document
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();

      // 3. Delete the user from Firebase Authentication
      await user!.delete();

      // 4. Sign out and redirect to login
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (_imageUrl != null ? NetworkImage(_imageUrl!) : null)
                          as ImageProvider?,
                  child: _imageFile == null && _imageUrl == null
                      ? const Icon(Icons.camera_alt, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter full name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    _dobController.text =
                        '${picked.day}/${picked.month}/${picked.year}';
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Gender:'),
                  const SizedBox(width: 16),
                  ChoiceChip(
                    label: const Text('Male'),
                    selected: _isMale,
                    onSelected: (val) => setState(() => _isMale = true),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Female'),
                    selected: !_isMale,
                    onSelected: (val) => setState(() => _isMale = false),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50)),
                child: const Text('Save'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _deleteAccount,
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Delete Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
