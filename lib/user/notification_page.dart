import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'event_detail.dart';

class NotificationPage extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;

  const NotificationPage({required this.notifications, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xffffffff),
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xff436b87),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xfffffef2), Color(0xfffffef2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: List.generate(notifications.length, (index) {
              final notification = notifications[index];
              final title = notification['title'] ?? 'No Title';
              final image = notification['image'] ?? '';
              final description =
                  notification['description'] ?? 'No Description';
              final price = notification['price'] ?? '0';
              final location = notification['location'] ?? 'No Location';
              final dateStr =
                  notification['date'] ?? ''; // Ensure date is a string
              DateTime date;

              try {
                date = DateTime.parse(dateStr);
              } catch (e) {
                date =
                    DateTime.now(); // Fallback to current date if parsing fails
              }

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailsPage(
                        title: title,
                        description: description,
                        price: price,
                        imageUrl: image,
                        location: location,
                        date: date,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Color(0xffecfefe),
                    border: Border.all(color: Color(0xffecfefe)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: image.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(image,
                                width: 40, height: 40, fit: BoxFit.cover),
                          )
                        : Icon(Icons.image, size: 40, color: Color(0xffffb322)),
                    title: Text(
                      title,
                      style: TextStyle(color: Color(0xff0a2942)),
                    ),
                    subtitle: Text(
                      "New event added: $title",
                      style: TextStyle(color: Color(0xff0a2942)),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
