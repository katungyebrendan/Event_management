import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class UploadImagePage extends StatefulWidget {
  @override
  _UploadImagePageState createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> {
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  Uint8List? _webImage;
  String _title = '';
  String _description = '';
  DateTime _date = DateTime.now();
  double _price = 0.0;

  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
        });
      } else {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _uploadData() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      String? imageUrl;
      if (_imageFile != null || _webImage != null) {
        try {
          // Upload image to Firebase Storage
          String fileName = (_imageFile != null
              ? _imageFile!.path.split('/').last
              : 'web_image.png');
          Reference firebaseStorageRef =
              FirebaseStorage.instance.ref().child('images/$fileName');
          UploadTask uploadTask;

          if (kIsWeb && _webImage != null) {
            uploadTask = firebaseStorageRef.putData(_webImage!);
          } else if (_imageFile != null) {
            uploadTask = firebaseStorageRef.putFile(_imageFile!);
          } else {
            throw Exception("No image selected");
          }

          TaskSnapshot taskSnapshot = await uploadTask;
          imageUrl = await taskSnapshot.ref.getDownloadURL();
        } catch (e) {
          print('Error uploading data: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading data')),
          );
          return;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select an image')),
        );
        return;
      }

      try {
        // Get the current user's UID
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception("No authenticated user");
        }

        // Save data to Firestore with the organizerId
        await FirebaseFirestore.instance.collection('events').add({
          'title': _title,
          'description': _description,
          'date': _date,
          'price': _price,
          'imageUrl': imageUrl,
          'organizerId': user.uid, // Add the organizer ID
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event added successfully!')),
        );

        // Clear form
        _formKey.currentState?.reset();
        setState(() {
          _imageFile = null;
          _webImage = null;
        });

        // Navigate back to the home page after successful upload
        Navigator.pop(context);
      } catch (e) {
        print('Error saving data to Firestore: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data to Firestore')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _title = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _description = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _price = double.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Date'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null && pickedDate != _date)
                      setState(() {
                        _date = pickedDate;
                      });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a date';
                    }
                    return null;
                  },
                  controller: TextEditingController(
                    text: "${_date.toLocal()}".split(' ')[0],
                  ),
                ),
                TextButton(
                  onPressed: _pickImage,
                  child: Text('Pick Image'),
                ),
                if (_imageFile != null)
                  Image.file(_imageFile!)
                else if (_webImage != null)
                  Image.memory(_webImage!),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _uploadData,
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
