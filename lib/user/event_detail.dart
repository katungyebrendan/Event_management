import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'map_page.dart';

class EventDetailsPage extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final String imageUrl;
  final String location;
  final DateTime date;

  const EventDetailsPage({
    Key? key,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.location,
    required this.date,
  }) : super(key: key);

  Future<Map<String, double>> getCoordinates(String locationName) async {
    final apiKey =
        'YOUR_API_KEY'; // Replace with your Google Maps Geocoding API key
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$locationName&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        return {
          'latitude': location['lat'],
          'longitude': location['lng'],
        };
      }
    }
    return {'latitude': 0.0, 'longitude': 0.0};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: Colors.grey,
                    width: double.infinity,
                    height: 250,
                    child: const Icon(Icons.image, size: 100),
                  ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('yyyy-MM-dd').format(date),
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final coordinates = await getCoordinates(location);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapPage(
                            location: location,
                            latitude: coordinates['latitude']!,
                            longitude: coordinates['longitude']!,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Location: $location',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Price: $price',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
