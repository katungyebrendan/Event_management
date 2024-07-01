import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final BuildContext context;

  NotificationService(this.context) {
    if (!kIsWeb) {
      FirebaseMessaging.instance.subscribeToTopic('events');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showNewEventNotification(message.notification);
      }
    });

    FirebaseFirestore.instance
        .collection('events')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          var eventData = change.doc.data() as Map<String, dynamic>?;
          if (eventData != null) {
            _showNewEventNotificationFromFirestore(eventData);
          }
        }
      }
    });
  }

  void _showNewEventNotification(RemoteNotification? notification) {
    if (notification == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(notification.title ?? 'New Event Posted!'),
          content: Text(notification.body ?? 'Check out the new event!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showNewEventNotificationFromFirestore(Map<String, dynamic> event) {
    if (event['name'] != null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('New Event Posted!'),
            content: Text('Check out the new event: ${event['name']}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
