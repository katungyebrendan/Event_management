class User {
  final String id;
  final List<String> preferredCategories;

  User({required this.id, required this.preferredCategories});
}

class Event {
  final String id;
  final String category;
  final String title;
  final List<String> keywords;

  Event(
      {required this.id,
      required this.category,
      required this.title,
      required this.keywords});
}

class UserSearchHistory {
  final String userId;
  final List<String> searchKeywords;

  UserSearchHistory({required this.userId, required this.searchKeywords});
}
