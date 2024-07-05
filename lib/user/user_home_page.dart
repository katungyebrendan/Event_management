import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:intl/intl.dart';
import '../auth/login_page.dart';
import 'event_detail.dart';
import 'search_service.dart';
import 'models.dart';
import 'recommendation_service.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({Key? key}) : super(key: key);

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();
  final RecommendationService _recommendationService = RecommendationService();
  String _searchQuery = '';
  String _selectedCategory = 'music'; // Default category
  bool _showRecommended = false; // Toggle for showing recommended events

  @override
  void initState() {
    super.initState();
  }

  Future<List<Event>> _fetchRecommendedEvents() async {
    final user = auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await _recommendationService.fetchRecommendedEvents(user.uid);
    }
    return [];
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
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showCategoryDialog(context),
                    child: Text('Select Category: $_selectedCategory'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showRecommended = !_showRecommended;
                    });
                  },
                  child: Text(_showRecommended
                      ? 'Show All Events'
                      : 'Show Recommended'),
                ),
              ],
            ),
          ),
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
                  _searchQuery = value.toLowerCase();
                });
                if (_searchQuery.isNotEmpty) {
                  _searchService.storeSearchKeywords(_searchQuery);
                }
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Event>>(
              future: _showRecommended
                  ? _fetchRecommendedEvents()
                  : _searchService.searchEvents(
                      _selectedCategory, _searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No upcoming events yet.'));
                }

                var filteredDocs = snapshot.data!;

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    var event = filteredDocs[index];
                    var title = event.title;
                    var description = event.description;
                    var price = event.price;
                    var imageUrl = event.imageUrl;
                    var date = event.date;

                    return Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  width: double.infinity,
                                  height: 300,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.grey,
                                  width: double.infinity,
                                  height: 300,
                                  child: const Icon(Icons.image, size: 100),
                                ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              DateFormat('yyyy-MM-dd').format(date),
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
                                      title: title,
                                      description: description,
                                      price: price,
                                      imageUrl: imageUrl,
                                      date: date,
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
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Category'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  child: const Text('Music'),
                  onTap: () {
                    setState(() {
                      _selectedCategory = 'music';
                    });
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  child: const Text('Dinner'),
                  onTap: () {
                    setState(() {
                      _selectedCategory = 'dinner';
                    });
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  child: const Text('Sports'),
                  onTap: () {
                    setState(() {
                      _selectedCategory = 'sports';
                    });
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  child: const Text('Cinema'),
                  onTap: () {
                    setState(() {
                      _selectedCategory = 'cinema';
                    });
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  child: const Text('Beach Parties'),
                  onTap: () {
                    setState(() {
                      _selectedCategory = 'beach_parties';
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
