import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ticket_widget/ticket_widget.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class TicketsPage extends StatelessWidget {
  final String title;

  final String price;
  final String location;
  final DateTime date;

  const TicketsPage({
    Key? key,
    required this.title,
    required this.price,
    required this.location,
    required this.date,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Your Ticket'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        backgroundColor: Colors.blueGrey,
        body: SingleChildScrollView(
          child: Center(
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
                    ]),
              ),
            ),
          ),
          //  Padding(
          // padding: const EdgeInsets.all(16.0),
          // child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          // children: [
          // Text(
          //   title,
          //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          // ),
          // SizedBox(height: 8),
          // SizedBox(height: 8),
          // Text(
          //   'Price: $price',
          //   style: TextStyle(fontSize: 16),
          // ),
          // SizedBox(height: 8),
          // Text(
          //   'Location: $location',
          //   style: TextStyle(fontSize: 16),
          // ),
          // SizedBox(height: 8),
          // Text(
          //   'Date: ${DateFormat('yyyy-MM-dd').format(date)}',
          //   style: TextStyle(fontSize: 16),
          // ),
          // ],
          // ),
          // ),
        ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyTicketView(),
    );
  }
}

// class TicketsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: Text('Tickets'),
//       // ),
//       body: MyTicketView(), // Use your ticket view here
//     );
//   }
// }

class MyTicketView extends StatelessWidget {
  const MyTicketView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.blueGrey,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: TicketWidget(
              width: 300,
              height: 600,
              isCornerRounded: true,
              padding: EdgeInsets.all(20),
              child: TicketData(),
            ),
          ),
        ),
      ),
    );
  }
}

class TicketData extends StatelessWidget {
  const TicketData({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.assignment_turned_in_rounded,
                    color: Colors.pink,
                  ),
                ),
              ],
            )
          ],
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
        Padding(
          padding: const EdgeInsets.only(top: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // children: [
            //   Text(
            //     'title:$title',
            //     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            //   ),
            //   SizedBox(height: 8),
            //   SizedBox(height: 8),
            //   Text(
            //     'Price:$price',
            //     style: TextStyle(fontSize: 16),
            //   ),
            //   SizedBox(height: 8),
            //   Text(
            //     'Location: $location',
            //     style: TextStyle(fontSize: 16),
            //   ),
            //   SizedBox(height: 8),
            //   Text(
            //     'Date: ${DateFormat('yyyy-MM-dd').format(date)}',
            //     style: TextStyle(fontSize: 16),
            //   ),
            // ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
              top: 40.0, left: 20.0, right: 20.0, bottom: 10.0),
          child: QrImageView(
            data: '+256778565958', // Replace with your dynamic QR code data
            version: QrVersions.auto,
            size: 200.0,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 10.0, left: 75.0, right: 75.0),
          child: Text(
            'have a nice time ',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}

Widget ticketDetailsWidget(String firstTitle, String firstDesc,
    String secondTitle, String secondDesc) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              firstTitle,
              style: const TextStyle(color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                firstDesc,
                style: const TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              secondTitle,
              style: const TextStyle(color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                secondDesc,
                style: const TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
      )
    ],
  );
}
