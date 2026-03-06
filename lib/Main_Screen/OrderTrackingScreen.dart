import 'package:flutter/material.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Track Order"),
        backgroundColor: const Color.fromARGB(177, 8, 46, 92),
      ),
      body: Center(
        child: Text(
          "Tracking details for Order ID: $orderId",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
