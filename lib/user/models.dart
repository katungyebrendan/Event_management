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
  final List<String> keywords;
  final String description;
  final String price;
  final String imageUrl;
  final DateTime date;

  Event({
    required this.id,
    required this.category,
    required this.title,
    required this.keywords,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.date,
  });

  factory Event.fromDocument(DocumentSnapshot doc, String category) {
    return Event(
      id: doc.id,
      category: category,
      title: doc['title'] ?? 'No Title',
      keywords: List<String>.from(doc['keywords'] ?? []),
      description: doc['description'] ?? 'No Description',
      price: doc['price'] ?? 'No Price',
      imageUrl: doc['imageUrl'] ?? '',
      date: (doc['date'] as Timestamp).toDate(),
    );
  }
}
