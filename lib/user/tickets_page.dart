import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ticket_widget/ticket_widget.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class TicketsPage extends StatelessWidget {
  final String title;
  final String price;
  final String location;
  final DateTime date;

  TicketsPage({
    Key? key,
    required this.title,
    required this.price,
    required this.location,
    required this.date,
  }) : super(key: key);

  final ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Your Ticket',
          style: TextStyle(
            color: Color(0xffffffff),
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.blueGrey,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () async {
                  await _captureAndSavePng(context);
                },
                child: Text('Download Ticket'),
              ),
            ),
            Screenshot(
              controller: screenshotController,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: TicketWidget(
                  width: 300,
                  height: 600,
                  isCornerRounded: true,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 220.0),
                            child: Icon(
                              Icons.assignment_turned_in_rounded,
                              color: Colors.pink,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 120.0,
                        height: 25.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          border: Border.all(width: 1.0, color: Colors.green),
                        ),
                        child: const Center(
                          child: Text(
                            'FUNEXPO',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Text(
                          'EVENT TICKET',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Price: $price',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Location: $location',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Date: ${DateFormat('yyyy-MM-dd').format(date)}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 40.0, left: 20.0, right: 20.0, bottom: 10.0),
                        child: QrImageView(
                          data:
                              '+256778565958', // Replace with your dynamic QR code data
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(top: 10.0, left: 75.0, right: 75.0),
                        child: Text(
                          'have a nice time ',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureAndSavePng(BuildContext context) async {
    try {
      // Request storage permissions
      if (await _requestPermissions()) {
        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          throw Exception('Failed to get external storage directory');
        }

        // Define the downloads directory
        final downloadsDirectory = Directory('${directory.path}/Download');
        if (!downloadsDirectory.existsSync()) {
          downloadsDirectory.createSync(recursive: true);
        }

        final filePath = '${downloadsDirectory.path}/ticket.png';
        final image = await screenshotController.capture();

        if (image != null) {
          final file = File(filePath);
          await file.writeAsBytes(image);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ticket saved to ${file.path}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission denied')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving ticket')),
      );
    }
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return false;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TicketsPage(
        title: 'Sample Event',
        price: '\$50',
        location: 'Sample Location',
        date: DateTime.now(),
      ),
    );
  }
}
