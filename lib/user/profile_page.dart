import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final user = auth.FirebaseAuth.instance.currentUser;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            readOnly: true,
            controller: TextEditingController(text: user?.email ?? 'No Email'),
          ),
          SizedBox(height: 16.0),
          TextField(
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            readOnly: true,
            controller: TextEditingController(text: 'password123'),
          ),
          SizedBox(height: 16.0),
          _profileImage == null
              ? Text('No image selected.')
              : Image.file(
                  _profileImage!,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Select Profile Image'),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              // Handle profile update logic here
            },
            child: Text('Update Profile'),
          ),
        ],
      ),
    );
  }
}
