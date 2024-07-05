import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';
import 'data_service.dart';

class RecommendationService {
  final DataService _dataService = DataService();

  Future<List<Event>> fetchRecommendedEvents(String userId) async {
    User user = await _dataService.fetchUserInterests(userId);
    UserSearchHistory searchHistory =
        await _dataService.fetchUserSearchHistory(userId);

    List<Event> recommendedEvents = [];

    // Fetch events from the categories
    for (String category in user.preferredCategories) {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection(category).get();
      recommendedEvents.addAll(snapshot.docs.map((doc) {
        return Event.fromDocument(doc, category);
      }).toList());
    }

    // Filter events based on user search history
    recommendedEvents = recommendedEvents.where((event) {
      return searchHistory.searchKeywords.any((keyword) =>
          event.title.toLowerCase().contains(keyword.toLowerCase()) ||
          event.keywords
              .any((k) => k.toLowerCase().contains(keyword.toLowerCase())));
    }).toList();

    return recommendedEvents;
  }
}
