import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

Future<void> sendOrderEmail({
  required BuildContext context,
  String userName = "Customer", // default
  required String userEmail,
  required String orderId,
  required double totalAmount,
  required List<Map<String, dynamic>> itemsList,
}) async {
  // 🔥 Validate Email
  if (userEmail.isEmpty || !userEmail.contains("@")) {
    print("❌ ERROR: User email is EMPTY or INVALID => $userEmail");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("⚠️ Invalid email. Cannot send order email."),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // Format items into a single string
  String formattedItems = "";
  for (var item in itemsList) {
    formattedItems +=
        "Name: ${item['name']}, Brand: ${item['brand']}, Qty: ${item['quantity']}, Total: ${item['total']}\n";
  }

  // EmailJS Keys
  const serviceId = "service_73m7jc3";
  const templateId = "template_javr0et";
  const publicKey = "8OsTIBc4Qchw0XOnf";

  final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");

  // 🔎 Debug Logs
  print("📩 Sending order email...");
  print("User Email: $userEmail");
  print("Order ID: $orderId");
  print("Items:\n$formattedItems");
  print("Total Amount: $totalAmount");

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "service_id": serviceId,
        "template_id": templateId,
        "user_id": publicKey,
        "template_params": {
          "user_email": userEmail.trim(),
          "name": userName,
          "order_id": orderId,
          "items": formattedItems,
          "total_amount": totalAmount.toStringAsFixed(2),
        },
      }),
    );

    // Success
    if (response.statusCode == 200) {
      print("✅ EmailJS SUCCESS 200");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("📩 Email sent successfully to $userEmail"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      print("❌ EmailJS ERROR: ${response.statusCode}");
      print("Response: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⚠️ Failed to send email. Error: ${response.body}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    print("❌ Exception: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("⚠️ Exception sending email: $e"),
        backgroundColor: Colors.red,
      ),
    );
  }
}
