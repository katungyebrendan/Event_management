import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:intl/intl.dart';
import '../auth/login_page.dart';
import 'event_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_page.dart';
import 'notification_service.dart'; // Import NotificationService

class UserHomePage extends StatefulWidget {
  const UserHomePage({Key? key}) : super(key: key);

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showRecommended = false; // Toggle for showing recommended events
  late NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _notificationService =
        NotificationService(context); // Initialize NotificationService
  }

  Future<List<Map<String, dynamic>>> _fetchRecommendedEvents() async {
    final user = auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Implement your logic to fetch recommended events for the user
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> _fetchEvents(String category) async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection(category).get();
    final events = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
    return events;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FunExpo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await auth.FirebaseAuth.instance.signOut();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationPage(
                    notifications: _notificationService.notifications,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.FirebaseAuth.instance.signOut();
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Events',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  // Handle search query change
                });
              },
            ),
          ),
          if (_showRecommended)
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchRecommendedEvents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No recommended events yet.'));
                  }

                  var events = snapshot.data!;

                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      var event = events[index];
                      return EventCard(event: event);
                    },
                  );
                },
              ),
            )
          else
            Expanded(
              child: ListView(
                children: [
                  _buildCategorySection('Music'),
                  _buildCategorySection('Cinema'),
                  _buildCategorySection('Sports'),
                  _buildCategorySection('Dinner'),
                  _buildCategorySection('Beach Parties'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String category) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchEvents(category.toLowerCase().replaceAll(' ', '_')),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No events available.'));
        }

        var events = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                category,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 290, // Reduced height to avoid overflow
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  var event = events[index];
                  return SizedBox(
                    width: 200,
                    child: EventCard(event: event),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventCard({required this.event, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final date = event['date'];
    DateTime? eventDate;
    if (date is Timestamp) {
      eventDate = date.toDate();
    } else if (date is DateTime) {
      eventDate = date;
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          event['imageUrl'] != null && event['imageUrl'].isNotEmpty
              ? Image.network(
                  event['imageUrl'],
                  width: double.infinity,
                  height: 150, // Adjusted height to avoid overflow
                  fit: BoxFit.cover,
                )
              : Container(
                  color: Colors.grey,
                  width: double.infinity,
                  height: 150, // Adjusted height to avoid overflow
                  child: const Icon(Icons.image, size: 100),
                ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              event['title'] ?? 'No Title',
              style: const TextStyle(
                fontSize: 16, // Adjusted font size to avoid overflow
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              eventDate != null
                  ? DateFormat('yyyy-MM-dd').format(eventDate)
                  : 'No Date',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailsPage(
                      title: event['title'] ?? 'No Title',
                      description: event['description'] ?? 'No Description',
                      price: event['price']?.toString() ?? 'No Price',
                      imageUrl: event['imageUrl'] ?? '',
                      location: event['location'] ?? '',
                      date: eventDate ?? DateTime.now(),
                    ),
                  ),
                );
              },
              child: const Text('Details'),
            ),
          ),
        ],
      ),
    );
  }
}
