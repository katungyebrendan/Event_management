import 'package:flutter/material.dart';
import 'package:flutterwave_standard/flutterwave.dart';

class PaymentForm extends StatefulWidget {
  final Function(bool) onPaymentProcessed;
  final String price;

  const PaymentForm({
    Key? key,
    required this.onPaymentProcessed,
    required this.price,
  }) : super(key: key);

  @override
  _PaymentFormState createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "FunExpo",
          style: TextStyle(
            color: Color(0xffffffff),
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xff152377),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xfffffef2), Color(0xfffffef2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff3b372c),
                  ),
                ),
                SizedBox(height: 20),
                Image.asset('assets/images/flutterwave_logo.png'),
                SizedBox(height: 20),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    labelStyle: TextStyle(color: Color(0xff0a0a33)),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff152377)),
                    ),
                  ),
                  readOnly: true,
                  style: TextStyle(color: Color(0xff0a0a33)),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(color: Color(0xff0a0a33)),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff152377)),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Color(0xff0a0a33)),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff152377)),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _makePayment(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff152377),
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    child: Text(
                      "Pay now",
                      style: TextStyle(color: Color(0xffffffff)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _makePayment(BuildContext context) async {
    final Customer customer = Customer(
      name: "Test User",
      phoneNumber: _phoneController.text,
      email: _emailController.text,
    );

    final Flutterwave flutterwave = Flutterwave(
      context: context,
      publicKey: "FLWPUBK_TEST-e95e5a70e687c4d58467ca9c0522a1a5-X",
      currency: "UGX",
      amount: _amountController.text,
      customer: customer,
      paymentOptions: "card, mobilemoneyuganda",
      txRef: "TXREF-${DateTime.now().millisecondsSinceEpoch}",
      isTestMode: true,
      customization: Customization(
        title: "Test Payment",
        description: "Payment for testing",
        logo: "https://your-logo-url.com/logo.png",
      ),
      redirectUrl: "https://example.com",
    );

    try {
      final ChargeResponse response = await flutterwave.charge();
      widget.onPaymentProcessed(true);
      _showMessage(context, "Payment processed successfully");
      Navigator.pop(context, true);
    } catch (error) {
      widget.onPaymentProcessed(false);
      _showMessage(context, "An error occurred during payment");
      Navigator.pop(context, false);
    }
  }

  void _showMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Payment Status"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
