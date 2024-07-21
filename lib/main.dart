import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'homepage.dart'; // Import your existing homepage
import 'package:permission_handler/permission_handler.dart';

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
      debugShowCheckedModeBanner: false, // Disable the debug banner
      title: 'Event Booking App',
      home:
          HomePageWrapper(), // Use the HomePageWrapper to initialize NotificationService
    );
  }
}

class HomePageWrapper extends StatefulWidget {
  @override
  _HomePageWrapperState createState() => _HomePageWrapperState();
}

class _HomePageWrapperState extends State<HomePageWrapper> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      await Permission.location.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize NotificationService if required

    return HomePage(); // Return the actual HomePage widget
  }
}
