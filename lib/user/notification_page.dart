import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;

  const NotificationPage({required this.notifications, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          final title = notification['title'] ?? 'No Title';
          final description = notification['description'] ?? 'No Description';
          final price = notification['price']?.toString() ?? 'No Price'; // Ensure price is a String
          final location = notification['location'] ?? '';
          final image = notification['image'] ?? '';
          final date = notification['date'];

          return ListTile(
            leading: image.isNotEmpty
                ? Image.network(image, width: 50, height: 50)
                : Icon(Icons.image, size: 50),
            title: Text(title),
            subtitle: Text(
                '$description\nPrice: $price\nLocation: $location\nDate: ${date.toString()}'),
          );
        },
      ),
    );
  }
}
