import 'package:flutter/material.dart';
import 'package:virtualmakeupapp/Main_Screen/home_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;
  final String userName; // ← new username field

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.userName, // ← required
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Order Success",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(177, 8, 46, 92),
      ),

      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 100),
              SizedBox(height: 16),
              Text(
                "Thanks! Your order has been placed.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                "Order ID: $orderId",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(
                        userName: userName, // ← REAL username pass
                      ),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(177, 8, 46, 92),
                  minimumSize: Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Go to Home",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
