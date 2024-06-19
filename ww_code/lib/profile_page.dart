import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'utilities/utils.dart';

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
        Map<String, dynamic>? data =
            userDoc.data() as Map<String, dynamic>?;

        setState(() {
          _usernameController.text = data?['Username'] ?? '';
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
        'Username': _usernameController.text,
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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.photo),
                  onPressed: _pickImage,
                ),
                IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.camera_alt),
                  onPressed: _takePhoto,
                ),
              ],
            ),
            TextField(
              cursorColor: Colors.black,
              controller: _usernameController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color.fromARGB(255, 208, 208, 208),
                prefixIcon: Icon(Icons.person, color: Colors.black45),
                hintText: 'Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              cursorColor: Colors.black,
              controller: _bioController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color.fromARGB(255, 208, 208, 208),
                prefixIcon:Icon(Icons.edit_note_sharp, color: Colors.black45),
                hintText: 'Bio',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUserProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.white,
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Color(0xFF00A6DF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
