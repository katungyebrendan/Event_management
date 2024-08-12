import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'event_detail.dart'; // Ensure you import the EventDetailsPage

class RetrieveEventsPage extends StatefulWidget {
  final String location;

  RetrieveEventsPage({required this.location});

  @override
  _RetrieveEventsPageState createState() => _RetrieveEventsPageState();
}

class _RetrieveEventsPageState extends State<RetrieveEventsPage> {
  final List<String> _categories = [
    'music',
    'cinema',
    'sports',
    'dinner',
    'beach'
  ];

  Future<Position> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try to ask for permissions again
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Radius of the Earth in kilometers
    final double dLat = _degToRad(lat2 - lat1);
    final double dLon = _degToRad(lon2 - lon1);
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degToRad(double deg) => deg * (pi / 180);

  Future<List<DocumentSnapshot>> _fetchEvents(
      Position userPosition, String category, double radius) async {
    final collectionRef = FirebaseFirestore.instance.collection(category);
    final snapshot = await collectionRef.get();
    final events = snapshot.docs;

    return events.where((event) {
      final data = event.data() as Map<String, dynamic>?;
      if (data == null) return false;
      final lat = (data['latitude'] as num?)?.toDouble();
      final lon = (data['longitude'] as num?)?.toDouble();
      if (lat == null || lon == null) return false;
      final distance = _calculateDistance(
          userPosition.latitude, userPosition.longitude, lat, lon);
      return distance <= radius;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Events Near You',
          style: TextStyle(
            color: Color(0xffffffff),
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xff152377),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xfffffef2), Color(0xfffffef2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<Position>(
          future: _getUserLocation(),
          builder: (context, locationSnapshot) {
            if (locationSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (locationSnapshot.hasError) {
              return Center(child: Text('Error fetching location'));
            }

            if (!locationSnapshot.hasData) {
              return Center(child: Text('Unable to determine location'));
            }

            final userPosition = locationSnapshot.data!;

            return ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Find exciting events around you',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff3b372c),
                    ),
                  ),
                ),
                for (var category in _categories)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.capitalizeFirstLetter(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff0a0a33),
                          ),
                        ),
                        SizedBox(height: 8.0),
                        FutureBuilder<List<DocumentSnapshot>>(
                          future: _fetchEvents(userPosition, category, 30.0),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error fetching events'));
                            }

                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Center(child: Text('No events found'));
                            }

                            final events = snapshot.data!;

                            return Container(
                              height: 340, // Adjusted height to avoid overflow
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: events.length,
                                itemBuilder: (context, index) {
                                  final event = events[index];
                                  final data =
                                      event.data() as Map<String, dynamic>?;

                                  final title =
                                      data != null && data.containsKey('title')
                                          ? data['title'] as String
                                          : 'Untitled';
                                  final description = data != null &&
                                          data.containsKey('description')
                                      ? data['description'] as String
                                      : 'No description available';
                                  final price =
                                      data != null && data.containsKey('price')
                                          ? data['price'].toString()
                                          : 'N/A'; // Ensure price is a string
                                  final location = data != null &&
                                          data.containsKey('location')
                                      ? data['location'] as String
                                      : 'Location not specified';
                                  final image = data != null &&
                                          data.containsKey('imageUrl')
                                      ? data['imageUrl'] as String
                                      : '';
                                  final date =
                                      data != null && data.containsKey('date')
                                          ? data['date']
                                          : 'Date not specified';

                                  DateTime eventDate;
                                  if (date is Timestamp) {
                                    eventDate = date.toDate();
                                  } else if (date is DateTime) {
                                    eventDate = date;
                                  } else if (date is String) {
                                    eventDate = DateTime.tryParse(date) ??
                                        DateTime.now();
                                  } else {
                                    eventDate = DateTime.now();
                                  }

                                  return Container(
                                    width: 200, // Adjust the width as needed
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      color: const Color(0xffecfefe),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          image.isNotEmpty
                                              ? ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius
                                                              .vertical(
                                                          top: Radius.circular(
                                                              16)),
                                                  child: Image.network(image,
                                                      width: double.infinity,
                                                      height: 150,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                    return Center(
                                                      child: Text(
                                                        'Image failed to load',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    );
                                                  }))
                                              : Container(
                                                  color: Colors.grey,
                                                  width: double.infinity,
                                                  height: 150,
                                                  child: const Icon(Icons.image,
                                                      size: 100),
                                                ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              title,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff0a173a),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Text(description,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    color: Color(0xff0a173a))),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Price: UGX ${price}',
                                              style: const TextStyle(
                                                  color: Color(0xff0a173a)),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EventDetailsPage(
                                                      title: title,
                                                      description: description,
                                                      price: price,
                                                      imageUrl: image,
                                                      location: location,
                                                      date: eventDate,
                                                    ),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xffffffff),
                                                textStyle: const TextStyle(
                                                  color: Color(0xff0a173a),
                                                ),
                                              ),
                                              child: const Text('Details'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Extension method to capitalize the first letter of a string
extension StringCapitalization on String {
  String capitalizeFirstLetter() {
    if (this.isEmpty) {
      return '';
    }
    return '${this[0].toUpperCase()}${this.substring(1).toLowerCase()}';
  }
}
