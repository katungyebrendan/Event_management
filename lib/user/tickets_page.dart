import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:ticket_widget/ticket_widget.dart';

void main() {
  runApp(const MyApp());
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

class TicketsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Tickets'),
      // ),
      body: MyTicketView(), // Use your ticket view here
    );
  }
}

class MyTicketView extends StatelessWidget {
  const MyTicketView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: TicketWidget(
              width: 300,
              height: 470,
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
                // Text(
                //   'LHR',
                //   style: TextStyle(
                //       color: Colors.black, fontWeight: FontWeight.bold),
                // ),
                Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.assignment_turned_in_rounded,
                    color: Colors.pink,
                  ),
                ),
                // Padding(
                //   padding: EdgeInsets.only(left: 8.0),
                //   child: Text(
                //     'ISL',
                //     style: TextStyle(
                //         color: Colors.black, fontWeight: FontWeight.bold),
                //   ),
                // )
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
            children: [
              ticketDetailsWidget(
                  'Event name', 'kcca fc vs sc villa', 'Date', '28-08-2024'),
              Padding(
                padding: const EdgeInsets.only(top: 12.0, right: 52.0),
                child: ticketDetailsWidget(
                    'Booking ID', '76836A45', 'price', 'shs10,000'),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0, right: 53.0),
                child:
                    ticketDetailsWidget('name', 'john wick', 'venue', 'Golazo'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
              top: 40.0, left: 20.0, right: 20.0, bottom: 10.0),
          child: BarcodeWidget(
            barcode: Barcode.code128(),
            data: '+256778565958', // Replace with your dynamic barcode data
            width: 250.0,
            height: 80.0,
            drawText: true,
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
        // const SizedBox(height: 30),
        // const Text('simo')
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
