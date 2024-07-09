import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http; // Add this import
import 'dart:convert'; // Add this import

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
                  Text(
                    'Location: ${widget.location}',
                    style: TextStyle(
                      color: Colors.grey[600],
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
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentForm(
                            title: widget.title,
                            price: widget.price,
                          ),
                        ),
                      );
                    },
                    child: Text('Make Payment'),
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
  final String title;
  final String price;

  const PaymentForm({
    Key? key,
    required this.title,
    required this.price,
  }) : super(key: key);

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController amountController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();

  List<String> currencyList = <String>[
    'USD',
    'INR',
    'EUR',
    'JPY',
    'GBP',
    'AED'
  ];
  String selectedCurrency = 'USD';

  bool hasDonated = false;

  Future<void> initPaymentSheet() async {
    try {
      // 1. create payment intent on the client side by calling stripe api
      final data = await createPaymentIntent(
        amount: (int.parse(amountController.text) * 100).toString(),
        currency: selectedCurrency,
        name: nameController.text,
        address: addressController.text,
        pin: pincodeController.text,
        country: countryController.text,
      );

      // 2. initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          // Set to true for custom flow
          customFlow: false,
          // Main params
          merchantDisplayName: 'Test Merchant',
          paymentIntentClientSecret: data['client_secret'],
          // Customer keys
          customerEphemeralKeySecret: data['ephemeralKey'],
          customerId: data['id'],
          style: ThemeMode.dark,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent({
    required String amount,
    required String currency,
    required String name,
    required String address,
    required String pin,
    required String country,
  }) async {
    final url = 'https://api.stripe.com/v1/payment_intents';
    final headers = {
      'Authorization': 'Bearer YOUR_STRIPE_SECRET_KEY',
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    final body = {
      'amount': amount,
      'currency': currency,
      'payment_method_types[]': 'card',
      'etup_future_usage': 'off_session',
      'hipping[name]': name,
      'hipping[address][line1]': address,
      'hipping[address][postal_code]': pin,
      'hipping[address][country]': country,
    };

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Use jsonDecode from dart:convert
    } else {
      throw Exception('Failed to create payment intent');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Form - ${widget.title}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "My Payment",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: "Amount",
                      hintText: "Any amount you like",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedCurrency,
                  onChanged: (String? value) {
                    setState(() {
                      selectedCurrency = value!;
                    });
                  },
                  items: currencyList
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                )
              ],
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                hintText: "Ex. John Doe",
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: "Address Line",
                hintText: "Ex. 123 Main St",
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: "City",
                      hintText: "Ex. New Delhi",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your city';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: "State (Short code)",
                      hintText: "Ex. DL for Delhi",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your state';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    controller: countryController,
                    decoration: const InputDecoration(
                      labelText: "Country (Short Code)",
                      hintText: "Ex. IN for India",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your country';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    controller: pincodeController,
                    decoration: const InputDecoration(
                      labelText: "Pincode",
                      hintText: "Ex. 123456",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your pincode';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.shade400),
                child: Text(
                  "Proceed to Pay",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await initPaymentSheet();

                    try {
                      await Stripe.instance.presentPaymentSheet();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Payment Done",
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );

                      setState(() {
                        hasDonated = true;
                      });
                      nameController.clear();
                      addressController.clear();
                      countryController.clear();
                      pincodeController.clear();
                    } catch (e) {
                      print("payment sheet failed");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Payment Failed",
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
