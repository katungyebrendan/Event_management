import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:intl/intl.dart';
import '../auth/login_page.dart';
import 'event_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_page.dart';
import 'notification_service.dart'; // Import NotificationService
import 'retrieve_events.dart'; // Import the RetrieveEventsPage
import 'tickets_page.dart';
import 'profile_page.dart'; // Import ProfilePage

class UserHomePage extends StatefulWidget {
  const UserHomePage({Key? key}) : super(key: key);

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showRecommended = false; // Toggle for showing recommended events
  late NotificationService _notificationService;
  int _selectedIndex = 0; // Track the selected tab
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

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

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
    });

    final querySnapshot = await FirebaseFirestore.instance
        .collectionGroup('events')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    final searchResults = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();

    setState(() {
      _searchResults = searchResults;
      _isSearching = false;
    });
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      // Navigate to RetrieveEventsPage directly when Explore tab is selected
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RetrieveEventsPage(
              location: 'example_location'), // Pass the location or category
        ),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xfffffef2), Color(0xfffffef2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _selectedIndex == 0
            ? _buildHomeContent()
            : _selectedIndex == 2
                ? TicketsPage()
                : ProfilePage(), // Show ProfilePage when Profile tab is selected
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
                backgroundColor: Color(0xff152377),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore, color: Color(0xffffffff)),
                label: 'Explore',
                backgroundColor: Color(0xff152377),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.confirmation_number, color: Color(0xffffffff)),
                label: 'Tickets',
                backgroundColor: Color(0xff152377),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, color: Color(0xffffffff)),
                label: 'Profile',
                backgroundColor: Color(0xff152377),
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Color(0xffffffff),
            // Change selected item color
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              filled: true, // fill the background with a color
              fillColor: Colors.white,
              labelText: 'Search Events',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              _performSearch(value);
            },
          ),
        ),
        if (_isSearching)
          const Center(child: CircularProgressIndicator())
        else if (_searchResults.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                var event = _searchResults[index];
                return EventCard(event: event);
              },
            ),
          )
        else if (_showRecommended)
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
                _buildCategorySection('Beach'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTicketsContent() {
    return Center(
      child: Text('Tickets Page Content'),
    );
  }

  Widget _buildProfileContent() {
    return ProfilePage(); // Return ProfilePage widget
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
                    width: 300, // Increased width for larger cards
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
      color: Color(0xff34424e),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          event['imageUrl'] != null && event['imageUrl'].isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.vertical(
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
                color: Color(0xffffb322),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              eventDate != null
                  ? DateFormat('yyyy-MM-dd').format(eventDate)
                  : 'No Date',
              style: TextStyle(color: Color(0xffffb322)),
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
                    fontWeight: FontWeight.bold, color: Color(0xff181716)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
