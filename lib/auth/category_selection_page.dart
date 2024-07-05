import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

class CategorySelectionPage extends StatefulWidget {
  final String userId;

  const CategorySelectionPage({required this.userId});

  @override
  _CategorySelectionPageState createState() => _CategorySelectionPageState();
}

class _CategorySelectionPageState extends State<CategorySelectionPage> {
  final List<String> _categories = [
    'Music',
    'Sports',
    'Cinema',
    'Beach Parties',
    'Dinner'
  ];
  final List<String> _selectedCategories = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Your Interests'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Select your interests:',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    return CheckboxListTile(
                      title: Text(_categories[index]),
                      value: _selectedCategories.contains(_categories[index]),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedCategories.add(_categories[index]);
                          } else {
                            _selectedCategories.remove(_categories[index]);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                ),
                onPressed: () async {
                  if (_selectedCategories.isNotEmpty) {
                    // Store selected categories in Firestore
                    await FirebaseFirestore.instance
                        .collection('userInterests')
                        .doc(widget.userId)
                        .set({
                      'userId': widget.userId,
                      'categories': _selectedCategories,
                      'updatedAt': Timestamp.now(),
                    });
                    // Navigate to the login page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Please select at least one category')),
                    );
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
