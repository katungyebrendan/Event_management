import 'package:cloud_firestore/cloud_firestore.dart'; // Import for Firestore
import 'package:firebase_auth/firebase_auth.dart'
    as auth; // Alias Firebase Auth
import 'models.dart'; // Correct import for Event model

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  // Store or update search keywords in Firestore
  Future<void> storeSearchKeywords(String query) async {
    auth.User? user = _auth.currentUser;

    if (user == null) {
      // Handle the case where the user is not signed in
      return;
    }

    final userId = user.uid;
    final searchHistoryRef =
        _firestore.collection('userSearchHistory').doc(userId);

    final searchHistoryDoc = await searchHistoryRef.get();
    if (searchHistoryDoc.exists) {
      // Update existing search history
      await searchHistoryRef.update({
        'searchKeywords': FieldValue.arrayUnion([query.toLowerCase()]),
      });
    } else {
      // Create a new search history document
      await searchHistoryRef.set({
        'userId': userId,
        'searchKeywords': [query.toLowerCase()],
      });
    }
  }

  // Search events based on query
  Future<List<Event>> searchEvents(String category, String query) async {
    final snapshot = await _firestore.collection(category).get();
    return snapshot.docs.map((doc) {
      return Event.fromDocument(doc, category);
    }).where((event) {
      return event.title.toLowerCase().contains(query.toLowerCase()) ||
          event.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
