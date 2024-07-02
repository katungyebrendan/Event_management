import 'package:flutter/material.dart';

class EventDetailsPage extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final String imageUrl;
  final DateTime? date; // Make date nullable

  EventDetailsPage({
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.date, // Make date nullable
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            imageUrl.isNotEmpty
                ? Image.network(imageUrl)
                : Placeholder(
                    fallbackHeight: 200.0,
                    fallbackWidth: double.infinity,
                  ),
            SizedBox(height: 16.0),
            Text(
              title,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(description),
            SizedBox(height: 8.0),
            Text('Price: $price'),
            SizedBox(height: 8.0),
            if (date != null)
              Text('Date: ${date!.toLocal().toString().split(' ')[0]}'),
          ],
        ),
      ),
    );
  }
}
