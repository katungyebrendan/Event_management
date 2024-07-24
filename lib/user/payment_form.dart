import 'package:flutter/material.dart';
import 'package:flutterwave_standard/flutterwave.dart';

class PaymentForm extends StatefulWidget {
  @override
  _PaymentFormState createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Flutterwave Payment")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _makePayment(context);
                  }
                },
                child: Text("Pay with Flutterwave"),
              ),
            ],
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
      publicKey:
          "FLWPUBK_TEST-e95e5a70e687c4d58467ca9c0522a1a5-X", // Ensure your public key is correct
      currency: "UGX",
      amount: _amountController.text,
      customer: customer,
      paymentOptions: "card, mobilemoneyuganda",
      txRef: "TXREF-${DateTime.now().millisecondsSinceEpoch}",
      isTestMode: true, // Set to false in production
      customization: Customization(
        title: "Test Payment",
        description: "Payment for testing",
        logo:
            "https://your-logo-url.com/logo.png", // Provide a URL for your logo
      ),
      redirectUrl:
          "https://example.com", // Replace with a proper redirect URL in production
    );

    try {
      final ChargeResponse response = await flutterwave.charge();
      _handleResponse(context, response);
    } catch (error) {
      print("Transaction error: $error");
      _showMessage(context, "Payment error: $error");
    }
  }

  void _handleResponse(BuildContext context, ChargeResponse response) {
    if (response != null) {
      if (response.status == 'success') {
        // Handle successful transaction here
        print("Transaction successful: ${response.toJson()}");
        _showMessage(context, "Payment successful!", response);
      } else {
        // Handle failed transaction here
        print("Transaction failed: ${response.toJson()}");
        _showMessage(context, "Payment failed", response);
      }
    } else {
      print("Transaction failed with no response");
      _showMessage(context, "Payment failed with no response");
    }
  }

  void _showMessage(BuildContext context, String message,
      [ChargeResponse? response]) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Payment Status"),
          content: Text(
              message + (response != null ? "\n\n${response.toJson()}" : "")),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
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
