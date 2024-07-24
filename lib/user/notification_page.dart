import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;

  const NotificationPage({required this.notifications, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: List.generate(notifications.length, (index) {
            final notification = notifications[index];
            final title = notification['title'] ?? 'No Title';
            final image = notification['image'] ?? '';

            return Container(
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xff0b253a)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: image.isNotEmpty
                    ? Image.network(image, width: 40, height: 40)
                    : Icon(Icons.image, size: 40),
                title: Text(title),
                subtitle: Text("New event added: $title"),
              ),
            );
          }),
        ),
      ),
    );
  }
}
