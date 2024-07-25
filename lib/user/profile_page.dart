import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? _username;
  String? _email;
  String? _profileImageUrl;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userData =
            await _firestore.collection('users').doc(user.uid).get();
        DocumentSnapshot profileData =
            await _firestore.collection('profile').doc(user.uid).get();

        setState(() {
          _username = userData['username'];
          _email = userData['email'];
          _profileImageUrl = profileData['profileImageUrl'];
        });
      }
    } catch (e) {
      print("Failed to load user data: $e");
    }
  }

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });

        User? user = _auth.currentUser;
        if (user != null) {
          String fileName = 'profile_${user.uid}.jpg';
          Reference storageRef = _storage.ref().child('images/$fileName');

          UploadTask uploadTask = storageRef.putFile(_imageFile!);
          TaskSnapshot taskSnapshot = await uploadTask;
          String downloadUrl = await taskSnapshot.ref.getDownloadURL();

          // Update only the 'profile' collection in Firestore
          await _firestore.collection('profile').doc(user.uid).set({
            'profileImageUrl': downloadUrl,
          }, SetOptions(merge: true));

          setState(() {
            _profileImageUrl = downloadUrl;
          });
        }
      }
    } catch (e) {
      print("Failed to upload image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _uploadImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : null,
                child: _profileImageUrl == null
                    ? Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            SizedBox(height: 20),
            Text('Username: ${_username ?? 'Loading...'}'),
            SizedBox(height: 10),
            Text('Email: ${_email ?? 'Loading...'}'),
          ],
        ),
      ),
    );
  }
}
