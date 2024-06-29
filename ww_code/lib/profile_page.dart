import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'utilities/utils.dart';
import 'aesthetics/textfield_style.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String? _profileImageUrl;
  final ImagePicker _picker = ImagePicker();
  late User _user;

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(_user.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;

        setState(() {
          _usernameController.text = data?['username'] ?? '';
          _bioController.text = data?['bio'] ?? '';
          _profileImageUrl = data?['profileImageUrl'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error loading user profile'),
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _uploadImage(pickedFile);
    }
  }

  Future<void> _takePhoto() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _uploadImage(pickedFile);
    }
  }

  Future<void> _uploadImage(XFile image) async {
    try {
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pics')
          .child('${_user.uid}.jpg');
      await storageRef.putFile(File(image.path));
      String downloadUrl = await storageRef.getDownloadURL();
      setState(() {
        _profileImageUrl = downloadUrl;
      });
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(_user.uid)
          .update({'profileImageUrl': downloadUrl});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error uploading image'),
        ),
      );
    }
  }

  Future<void> _resetProfilePicture() async {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Reset Profile Picture?',
              style: TextStyle(color: Colors.black)),
          content: const Text(
              'Are you sure you want to reset your profile picture?',
              style: TextStyle(color: Colors.black)),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.lightBlue)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Reset',
                  style: TextStyle(color: Colors.lightBlue)),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  setState(() {
                    _profileImageUrl = null;
                  });
                  await FirebaseFirestore.instance
                      .collection('Users')
                      .doc(_user.uid)
                      .update({'profileImageUrl': null});
                  if (_profileImageUrl != null) {
                    await FirebaseStorage.instance
                        .refFromURL(_profileImageUrl!)
                        .delete();
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile picture reset successfully!'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error resetting profile picture'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUserProfile() async {
    if (!isValidUsername(_usernameController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username must be between 4-15 characters'),
        ),
      );
      return;
    }

    if (!isValidBio(_bioController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bio must be not more than 30 characters'),
        ),
      );
      return;
    }
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(_user.uid)
          .update({
        'username': _usernameController.text,
        'bio': _bioController.text,
        'profileImageUrl': _profileImageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Personal information saved!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error saving information'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.iconTheme.color;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Stack(
              children: [
                if (_profileImageUrl != null)
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(_profileImageUrl!),
                  )
                else
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black45,
                    radius: 60,
                    child: Icon(
                      Icons.person,
                      size: 80,
                    ),
                  ),
                Positioned(
                  bottom: -15,
                  right: -15,
                  child: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _resetProfilePicture,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  color: Colors.white,
                  icon: Icon(Icons.photo, color: iconColor),
                  onPressed: _pickImage,
                ),
                IconButton(
                  color: Colors.white,
                  icon: Icon(Icons.camera_alt, color: iconColor),
                  onPressed: _takePhoto,
                ),
              ],
            ),
            TextField(
              cursorColor: Colors.black,
              style: const TextStyle(color: Colors.black),
              decoration: TextFieldConfig.buildInputDecoration(
                hintText: 'Username',
                controller: _usernameController,
                prefixIcon: const Icon(Icons.person, color: Colors.black45),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              cursorColor: Colors.black,
              style: const TextStyle(color: Colors.black),
              decoration: TextFieldConfig.buildInputDecoration(
                hintText: 'Bio',
                controller: _bioController,
                prefixIcon: const Icon(Icons.book, color: Colors.black45),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUserProfile,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
