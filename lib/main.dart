import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'homepage.dart'; // Import your existing homepage
import 'notification_service.dart'; // Import the NotificationService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Booking App',
      home:
          HomePageWrapper(), // Use the HomePageWrapper to initialize NotificationService
    );
  }
}

class HomePageWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Initialize NotificationService
    NotificationService(context);

    return HomePage(); // Return the actual HomePage widget
  }
}
