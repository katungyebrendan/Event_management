import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:intl/intl.dart';
import 'event_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_page.dart';
import 'notification_service.dart';
import 'retrieve_events.dart';
import 'tickets_page.dart';
import 'profile_page.dart';
import 'all_tickets_page.dart'; // Import the EventSearchDelegate

import 'event_search_delegate.dart'; // Import the EventSearchDelegate

class UserHomePage extends StatefulWidget {
  const UserHomePage({Key? key}) : super(key: key);

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  late NotificationService _notificationService;
  int _selectedIndex = 0; // Track the selected tab

  List<Map<String, dynamic>> allEvents = []; // Store all events for searching

  @override
  void initState() {
    super.initState();
    _notificationService =
        NotificationService(context); // Initialize NotificationService
    _fetchAllEvents(); // Fetch all events on init
  }

  Future<void> _fetchAllEvents() async {
    final categories = ['music', 'cinema', 'sports', 'dinner', 'beach'];
    List<Map<String, dynamic>> events = [];

    for (var category in categories) {
      final categoryEvents = await _fetchEvents(category);
      events.addAll(categoryEvents);
    }

    setState(() {
      allEvents = events;
    });
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0 // Only show AppBar for UserHomePage
          ? AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xff436b87),
              title: const Text(
                'FunExpo',
                style: TextStyle(
                  color: Color(0xffffffff),
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.search,
                    color: Color(0xffffffff),
                  ),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: EventSearchDelegate(allEvents),
                    );
                  },
                ),
                // IconButton(
                //   icon: const Icon(
                //     Icons.notifications,
                //     color: Color(0xfffefefe),
                //   ),
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => NotificationPage(
                //           notifications: _notificationService.notifications,
                //         ),
                //       ),
                //     );
                //   },
                // ),
              ],
            )
          : null, // No AppBar for other pages
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xfffffef2), Color(0xfffffef2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeContent(),
            RetrieveEventsPage(location: 'example_location'),
            NotificationPage(
              notifications: _notificationService.notifications,
            ),
            ProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40.0),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home, color: Color(0xffffffff)),
                label: 'Home',
                backgroundColor: Color(0xff012b53),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore, color: Color(0xffffffff)),
                label: 'Explore',
                backgroundColor: Color(0xff012b53),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications, color: Color(0xffffffff)),
                label: 'notifications',
                backgroundColor: Color(0xff012b53),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, color: Color(0xffffffff)),
                label: 'Profile',
                backgroundColor: Color(0xff012b53),
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xffffffff),
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: ListView(
            children: [
              _buildCategorySection('Music'),
              _buildCategorySection('Cinema'),
              _buildCategorySection('Sports'),
              _buildCategorySection('Dinner'),
              _buildCategorySection('Beach'),
            ],
          ),
        ),
      ],
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
              height: 380, // Increased height for larger cards
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  var event = events[index];
                  return SizedBox(
                    width: 250, // Increased width for larger cards
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // rounded edges
      ),
      color: const Color(0xffecfefe),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          event['imageUrl'] != null && event['imageUrl'].isNotEmpty
              ? ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)), // Rounded edges at the top
                  child: Image.network(
                    event['imageUrl'],
                    width: double.infinity,
                    height: 240, // Increased height for larger images
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  color: Colors.grey,
                  width: double.infinity,
                  height: 240, // Increased height for larger placeholder
                  child: const Icon(Icons.image, size: 100),
                ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              event['title'] ?? 'No Title',
              style: const TextStyle(
                fontSize: 20, // Increased font size
                fontWeight: FontWeight.bold,
                color: Color(0xff040424),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              eventDate != null
                  ? DateFormat('yyyy-MM-dd').format(eventDate)
                  : 'No Date',
              style: const TextStyle(color: Color(0xff040424)),
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
              child: const Text(
                'Details',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xff040424)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
