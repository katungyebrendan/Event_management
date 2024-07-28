import 'package:flutter/material.dart';
import 'event_detail.dart';
import 'package:intl/intl.dart';

class EventSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> events;

  EventSearchDelegate(this.events);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = events.where((event) {
      final titleLower = event['title']?.toLowerCase() ?? '';
      final queryLower = query.toLowerCase();

      return titleLower.contains(queryLower);
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return ListTile(
          title: Text(result['title'] ?? 'No Title'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailsPage(
                  title: result['title'] ?? 'No Title',
                  description: result['description'] ?? 'No Description',
                  price: result['price']?.toString() ?? 'No Price',
                  imageUrl: result['imageUrl'] ?? '',
                  location: result['location'] ?? '',
                  date: result['date']?.toDate() ?? DateTime.now(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = events.where((event) {
      final titleLower = event['title']?.toLowerCase() ?? '';
      final queryLower = query.toLowerCase();

      return titleLower.contains(queryLower);
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          title: Text(suggestion['title'] ?? 'No Title'),
          onTap: () {
            query = suggestion['title'] ?? 'No Title';
            showResults(context);
          },
        );
      },
    );
  }
}
