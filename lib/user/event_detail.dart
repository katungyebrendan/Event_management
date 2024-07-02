import 'package:flutter/material.dart';

@immutable
class EventDetailsPage extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final String imageUrl;
  final DateTime date;

  const EventDetailsPage({
    super.key,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.date,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : const Placeholder(
                    fallbackHeight: 200,
                    color: Colors.grey,
                  ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 8),
            Text(
              'Price: \$${price}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Date: ${date.toLocal()}'.split(' ')[0]),
          ],
        ),
      ),
    );
  }
}
