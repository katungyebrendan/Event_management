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
  String _selectedCollection = 'dinner'; // Default collection

  final List<String> _collections = [
    'dinner',
    'beach',
    'music',
    'cinema',
    'sports'
  ];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection(_selectedCollection).get();
    final events = querySnapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id; // Add the document ID to the event data
          return data;
        })
        .where((event) =>
            event['title'] != null &&
            event['description'] != null &&
            event['price'] != null &&
            event['date'] != null &&
            event['imageUrl'] != null)
        .toList(); // Filter events with all fields non-null
    setState(() {
      _events = events;
    });
  }

  Future<void> _createEventAndPickImage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadImagePage(collection: _selectedCollection),
      ),
    );
    _loadEvents(); // Reload events after creating a new one
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FunExpo'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DropdownButton<String>(
                  value: _selectedCollection,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCollection = newValue!;
                      _loadEvents();
                    });
                  },
                  items: _collections
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _createEventAndPickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('Add New Event'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Events:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _events.isEmpty
                  ? const Center(child: Text('No events available'))
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
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (event['imageUrl'] != null)
                                Image.network(
                                  event['imageUrl'],
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event['title'] ?? 'No Title',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      event['description'] ?? 'No Description',
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '\$${event['price']?.toStringAsFixed(2) ?? 'No Price'}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Date: ${eventDate != null ? DateFormat('yyyy-MM-dd').format(eventDate) : 'No Date'}',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.blue[50],
    );
  }
}
