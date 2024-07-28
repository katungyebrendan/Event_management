import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'map_page.dart';
import 'payment_form.dart'; // Import the new PaymentForm file
import 'tickets_page.dart' as tickets;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Money Deposit',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EventDetailsPage(
        title: 'Event Title',
        description: 'Event Description',
        price: '1000',
        imageUrl: 'https://via.placeholder.com/300',
        location: 'Kampala',
        date: DateTime.now(),
      ),
    );
  }
}

class EventDetailsPage extends StatefulWidget {
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
        'AIzaSyD_vc1qYbzEXnqCWREUKWF-V5PRckknhjA'; // Replace with your Google Maps Geocoding API key
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
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text(
          'Event Details',
          style: TextStyle(
            color: Color(0xffffffff),
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.imageUrl.isNotEmpty
                ? Image.network(
                    widget.imageUrl,
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
                    widget.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('yyyy-MM-dd').format(widget.date),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final coordinates =
                          await widget.getCoordinates(widget.location);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapPage(
                            location: widget.location,
                            latitude: coordinates['latitude']!,
                            longitude: coordinates['longitude']!,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Location: ${widget.location}',
                      style: TextStyle(
                        color: Color(0xff1d7679),
                        decoration: TextDecoration.underline,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Price: ${widget.price}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentForm(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffb97c0d),
                      foregroundColor: Color(0xffffffff),
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: const Text('Book Event'),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => tickets.TicketsPage(
                                title: widget.title,
                                price: widget.price,
                                location: widget.location,
                                date: widget.date,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff0c2e49),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          textStyle: TextStyle(fontSize: 18),
                        ),
                        child: const Text('Find Tickets'),
                      ),
                    ),
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
