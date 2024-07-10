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
          final image = notification['image'] ?? '';
          return ListTile(
              leading: image.isNotEmpty
                  ? Image.network(image, width: 40, height: 40)
                  : Icon(Icons.image, size: 40),
              title: Text(title),
              subtitle: Text("New event added (title)"));
        },
      ),
    );
  }
}
