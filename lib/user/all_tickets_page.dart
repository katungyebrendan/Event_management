// all_tickets_page.dart
import 'user_home_page.dart';
import 'package:flutter/material.dart';

class AllTicketsPage extends StatelessWidget {
  const AllTicketsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tickets'),
      ),
      body: Center(
        child: Text('List of all tickets will be displayed here.'),
      ),
    );
  }
}
