import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'map_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Money Deposit',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EventDetailsPage(
        title: 'Event Title',
        description: 'Event Description',
        price: '1000',
        imageUrl: 'https://via.placeholder.com/300',
        location: 'Kampala',
        date: DateTime.now(),
      ),
    );
  }
}

class EventDetailsPage extends StatefulWidget {
  final String title;
  final String description;
  final String price;
  final String imageUrl;
  final String location;
  final DateTime date;

  const EventDetailsPage({
    Key? key,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.location,
    required this.date,
  }) : super(key: key);

  Future<Map<String, double>> getCoordinates(String locationName) async {
    final apiKey =
        'AIzaSyD_vc1qYbzEXnqCWREUKWF-V5PRckknhjA'; // Replace with your Google Maps Geocoding API key
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$locationName&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        return {
          'latitude': location['lat'],
          'longitude': location['lng'],
        };
      }
    }
    return {'latitude': 0.0, 'longitude': 0.0};
  }

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            widget.imageUrl.isNotEmpty
                ? Image.network(
                    widget.imageUrl,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: Colors.grey,
                    width: double.infinity,
                    height: 250,
                    child: const Icon(Icons.image, size: 100),
                  ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('yyyy-MM-dd').format(widget.date),
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final coordinates =
                          await widget.getCoordinates(widget.location);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapPage(
                            location: widget.location,
                            latitude: coordinates['latitude']!,
                            longitude: coordinates['longitude']!,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Location: ${widget.location}',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Price: ${widget.price}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentForm(
                            price: widget.price,
                          ),
                        ),
                      );
                    },
                    child: const Text('Book Event'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentForm extends StatefulWidget {
  final String price;

  const PaymentForm({Key? key, required this.price}) : super(key: key);

  @override
  _PaymentFormState createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final _formKey = GlobalKey<FormState>();

  String _username = '3f576bd547c22941';
  String _password = 'c2838880b1b85a53';
  String _amount = '500';
  String _currency = 'UGX';
  String _phone = '256786533813';
  String _reference = '';
  String _reason = '';

  @override
  void initState() {
    super.initState();
    _amount = widget.price;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Form'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*TextFormField(
                  decoration: InputDecoration(labelText: 'Event Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the event name';
                    }
                    return null;
                  },
                  onSaved: (value) => _reason = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Event Date'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the event date';
                    }
                    return null;
                  },
                  onSaved: (value) => _reference = value!,
                ),*/
                SizedBox(height: 20),
                Text('Payment Details',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Username'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                  onSaved: (value) => _username = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  onSaved: (value) => _password = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Amount'),
                  initialValue: _amount,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the amount';
                    }
                    return null;
                  },
                  onSaved: (value) => _amount = value!,
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Currency'),
                  value: _currency,
                  onChanged: (String? newValue) {
                    setState(() {
                      _currency = newValue!;
                    });
                  },
                  items: <String>['UGX', 'USD', 'EUR']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                TextFormField(
                  decoration:
                      InputDecoration(labelText: 'Mobile Money Phone Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mobile money phone number';
                    }
                    return null;
                  },
                  onSaved: (value) => _phone = value!,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      makePayment();
                    }
                  },
                  child: Text('Make Payment'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> makePayment() async {
    final url =
        'https://www.easypay.co.ug/api/payments'; // Replace with actual EasyPay API endpoint

    final payload = {
      'username': '3f576bd547c22941',
      'password': 'c2838880b1b85a53',
      'action': 'mmdeposit',
      'amount': _amount,
      'currency': _currency,
      'phone': '0786533813',
      'reference': _reference,
      'reason': _reason,
    };

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      // Add any other headers that are required
    };

    String body = jsonEncode({
      'key1': 'amount',
      'key2': 'phone number',
      // Add any other data that you want to send in the request body
    });

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      // Handle success response
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment successful')),
      );
    } else {
      // Handle error response
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed')),
      );
    }
  }
}

/*
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment initiated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Error: ${response.statusCode} - ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

*/
