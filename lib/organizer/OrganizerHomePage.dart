import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'image_upload_page.dart'; // Ensure this import is correct

class OrganizerHomePage extends StatefulWidget {
  @override
  _OrganizerHomePageState createState() => _OrganizerHomePageState();
}

class _OrganizerHomePageState extends State<OrganizerHomePage> {
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('events').get();
    final events = querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Add the document ID to the event data
      return data;
    }).toList();
    setState(() {
      _events = events.cast<Map<String, dynamic>>();
    });
  }

  Future<void> _createEventAndPickImage() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadImagePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Event Organizer Home')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _createEventAndPickImage,
              child: Text('Add New Event'),
            ),
            SizedBox(height: 20),
            Text(
              'Events:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: _events.isEmpty
                  ? Center(child: Text('No events available'))
                  : ListView.builder(
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        final event = _events[index];
                        final date = event['date'];
                        DateTime? eventDate;
                        if (date is Timestamp) {
                          eventDate = date.toDate();
                        } else if (date is DateTime) {
                          eventDate = date;
                        }

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(event['title'] ?? 'No Title'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(event['description'] ?? 'No Description'),
                                Text(
                                  '\$${event['price']?.toStringAsFixed(2) ?? 'No Price'}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Date: ${eventDate != null ? DateFormat('yyyy-MM-dd').format(eventDate) : 'No Date'}',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
