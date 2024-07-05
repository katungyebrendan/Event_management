import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

class DataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch user interests
  Future<User> fetchUserInterests(String userId) async {
    DocumentSnapshot userDoc =
        await _db.collection('userInterests').doc(userId).get();
    if (userDoc.exists) {
      List<String> preferredCategories =
          List<String>.from(userDoc['categories']);
      return User(id: userId, preferredCategories: preferredCategories);
    } else {
      throw Exception("User document does not exist");
    }
  }

  // Fetch user search history
  Future<UserSearchHistory> fetchUserSearchHistory(String userId) async {
    DocumentSnapshot historyDoc =
        await _db.collection('userSearchHistories').doc(userId).get();
    if (historyDoc.exists) {
      List<String> searchKeywords =
          List<String>.from(historyDoc['searchKeywords']);
      return UserSearchHistory(userId: userId, searchKeywords: searchKeywords);
    } else {
      throw Exception("User search history document does not exist");
    }
  }

  // Fetch events from specific collections
  Future<List<Event>> fetchEvents() async {
    // List of event collections
    final List<String> collections = [
      'music',
      'dinner',
      'sports',
      'cinema',
      'beach_parties',
    ];

    List<Event> events = [];

    for (String collection in collections) {
      QuerySnapshot snapshot = await _db.collection(collection).get();
      events.addAll(snapshot.docs.map((doc) {
        return Event(
          id: doc.id,
          category: collection,
          title: doc['title'] ?? 'No Title',
          keywords: List<String>.from(doc['keywords'] ?? []),
          description: doc['description'] ?? 'No Description',
          price: doc['price'] ?? 'No Price',
          imageUrl: doc['imageUrl'] ?? '',
          date: (doc['date'] as Timestamp).toDate(),
        );
      }).toList());
    }

    return events;
  }
}
