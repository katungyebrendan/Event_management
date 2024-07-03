import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../auth/login_page.dart';
import 'event_detail.dart';
import 'search_service.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({Key? key}) : super(key: key);

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();
  String _searchQuery = '';
  String _selectedCategory = 'music'; // Default category
  bool _showRecommended = false; // Toggle for showing recommended events

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FunExpo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
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
              await FirebaseAuth.instance.signOut();
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
                SizedBox(width: 8),
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
            child: FutureBuilder<List<QueryDocumentSnapshot>>(
              future: _showRecommended
                  ? _searchService.getRecommendedEvents()
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
                    var event =
                        filteredDocs[index].data() as Map<String, dynamic>;
                    var title = event['title'] ?? 'No Title';
                    var description = event['description'] ?? 'No Description';
                    var price = event['price']?.toString() ?? 'No Price';
                    var imageUrl = event['imageUrl'] ?? '';
                    var date = (event['date'] as Timestamp?)?.toDate() ??
                        DateTime.now(); // Default to now if date is null

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
          content: DropdownButtonFormField<String>(
            value: _selectedCategory,
            items: const [
              DropdownMenuItem(value: 'music', child: Text('Music')),
              DropdownMenuItem(value: 'sports', child: Text('Sports')),
              DropdownMenuItem(value: 'cinema', child: Text('Cinema')),
              DropdownMenuItem(
                  value: 'beach parties', child: Text('Beach Parties')),
              DropdownMenuItem(value: 'dinner', child: Text('Dinner')),
            ],
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue!;
              });
              Navigator.pop(context);
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
