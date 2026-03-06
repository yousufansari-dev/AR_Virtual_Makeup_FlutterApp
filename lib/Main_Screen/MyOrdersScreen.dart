import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        backgroundColor: const Color.fromARGB(177, 8, 46, 92),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection("orders")
            .where("userId", isEqualTo: currentUser!.uid)
            .orderBy("timestamp", descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No Orders Found", style: TextStyle(fontSize: 18)),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              var items = order['items'];

              return Card(
                margin: const EdgeInsets.all(12),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Order ID: ${order.id}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.pink.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              order['status'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                items[i]['image'],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              items[i]['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text("Qty: ${items[i]['quantity']}"),
                            trailing: Text(
                              "Rs ${items[i]['price']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),
                      Text(
                        "Total: Rs ${order['totalAmount']}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 10),
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
