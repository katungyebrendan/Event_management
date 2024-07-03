import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Store or update search keywords in Firestore
  Future<void> storeSearchKeywords(String query) async {
    User? user = _auth.currentUser;

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
  Future<List<QueryDocumentSnapshot>> searchEvents(
      String category, String query) async {
    final snapshot = await _firestore.collection(category).get();
    return snapshot.docs.where((doc) {
      var data = doc.data() as Map<String, dynamic>;
      var title = data['title']?.toString().toLowerCase() ?? '';
      var description = data['description']?.toString().toLowerCase() ?? '';

      return title.contains(query.toLowerCase()) ||
          description.contains(query.toLowerCase());
    }).toList();
  }
}
