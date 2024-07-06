import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final List<String> preferredCategories;

  User({
    required this.id,
    required this.preferredCategories,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc.id,
      preferredCategories: List<String>.from(doc['categories'] ?? []),
    );
  }
}

class UserSearchHistory {
  final String userId;
  final List<String> searchKeywords;

  UserSearchHistory({
    required this.userId,
    required this.searchKeywords,
  });

  factory UserSearchHistory.fromDocument(DocumentSnapshot doc) {
    return UserSearchHistory(
      userId: doc.id,
      searchKeywords: List<String>.from(doc['searchKeywords'] ?? []),
    );
  }
}

class Event {
  final String id;
  final String category;
  final String title;
  final String description;
  final double price; // Change to double
  final String imageUrl;
  final DateTime date;
  final String location; // Add this field

  Event({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.date,
    required this.location,
  });

  factory Event.fromDocument(DocumentSnapshot doc, String category) {
    return Event(
      id: doc.id,
      category: category,
      title: doc['title'] ?? 'No Title',
      description: doc['description'] ?? 'No Description',
      price: (doc['price'] as num).toDouble(), // Convert price to double
      imageUrl: doc['imageUrl'] ?? '',
      location: doc['location'] ?? 'No location',
      date: (doc['date'] as Timestamp).toDate(),
    );
  }
}
