import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:virtualmakeupapp/Admin_Dashboard/sendOrderEmail.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  _AdminOrdersPageState createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Status Color Badge Function
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'delivered':
        return Colors.blue;
      case 'shipped':
        return Colors.teal;
      case 'processing':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Delete Order
  void deleteOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).delete();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Order Deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Orders',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(177, 8, 46, 92),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('orders')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return Center(child: Text("No orders yet."));
          }

          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              var orderId = order.id;

              var userEmail = order['userEmail'] ?? "N/A";
              var totalAmount = order['totalAmount'] ?? 0;
              var status =
                  order['status'] ?? "approved"; // Directly placed orders

              return Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email + Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              userEmail,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              overflow:
                                  TextOverflow.ellipsis, // Prevent overflow
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: getStatusColor(status),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 8),
                      Text('Order ID: $orderId'),
                      Text('Total Amount: $totalAmount PKR'),

                      SizedBox(height: 10),

                      // Send Mail + Delete buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: ElevatedButton(
                              onPressed: () async {
                                List<Map<String, dynamic>> products =
                                    List<Map<String, dynamic>>.from(
                                      order['items'] ?? [],
                                    );
                                double totalAmt = 0;
                                if (order['totalAmount'] != null) {
                                  totalAmt =
                                      double.tryParse(
                                        order['totalAmount'].toString(),
                                      ) ??
                                      0;
                                }
                                await sendOrderEmail(
                                  context: context,
                                  userName: order['userName'] ?? "Customer",
                                  userEmail:
                                      order['userEmail'] ?? "user@example.com",
                                  orderId: orderId,
                                  totalAmount: totalAmt,
                                  itemsList: products,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(100, 40),
                              ),
                              child: Text(
                                "Send Mail",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteOrder(orderId),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
