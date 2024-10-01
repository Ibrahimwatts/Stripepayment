// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = "pk_test_51Q1as4HTEh7fB2dg1bxkExcyo9kMXtNNAR2WQCNnsJV0avqgwbjbKYTWBqilDwoCWXhGc6SEqMIHRHwaVaXjoyOc00XWB8dsVT"; // Enter your publishable key here
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PaymentPage(),
    );
  }
}

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  Future<void> createPaymentIntent() async {
    try {
      // Replace with your backend endpoint
      final response = await http.post(
        Uri.parse('http://localhost:3000/create-payment-intent'),
        body: json.encode({
          'amount': 1000,  // Amount in cents (e.g., $10.00)
          'currency': 'usd'
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      final body = jsonDecode(response.body);
      await Stripe.instance.initPaymentSheet(paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: body['clientSecret'],
        merchantDisplayName: 'Your Business',
      ));

      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Successful!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stripe Payment')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            createPaymentIntent();
          },
          child: const Text('Pay Now'),
        ),
      ),
    );
  }
}
