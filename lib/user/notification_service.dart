import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final BuildContext context;
  final List<Map<String, dynamic>> notifications = [];

  final List<String> _categories = [
    'music',
    'dinner',
    'sports',
    'cinema',
    'beach_parties',
  ];

  NotificationService(this.context) {
    if (!kIsWeb) {
      FirebaseMessaging.instance.subscribeToTopic('events');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _addNotification({
          'title': message.notification!.title ?? 'No Title',
          'body': message.notification!.body ?? 'No Body',
        });
      }
    });

    // Listen to changes in all categories
    for (var category in _categories) {
      FirebaseFirestore.instance
          .collection(category)
          .snapshots()
          .listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            var eventData = change.doc.data() as Map<String, dynamic>?;
            if (eventData != null) {
              _addNotification({
                'title': eventData['title'] ?? 'No Title',
                'description': eventData['description'] ?? 'No Description',
                'price': eventData['price'] ?? 'No Price',
                'location': eventData['location'] ?? 'No Location',
                'image': eventData['image'] ?? '',
                'date': eventData['date'] != null
                    ? (eventData['date'] as Timestamp).toDate()
                    : DateTime.now(),
              });
            }
          }
        }
      });
    }
  }

  void _addNotification(Map<String, dynamic> notification) {
    print('Adding notification: $notification'); // Debug log
    notifications.add(notification);
  }
}
