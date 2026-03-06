import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:virtualmakeupapp/Admin_Dashboard/AddProductScreen.dart';
import 'package:virtualmakeupapp/Admin_Dashboard/AdminDashboard.dart';
import 'package:virtualmakeupapp/Admin_Dashboard/AdminOrdersPage.dart';
import 'package:virtualmakeupapp/Admin_Dashboard/ProductListScreen.dart';
import 'package:virtualmakeupapp/Admin_Dashboard/UserManagementScreen.dart';
import 'package:virtualmakeupapp/Login-Signup/LoginScreen.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final CollectionReference contactsRef = FirebaseFirestore.instance.collection(
    'contact_messages',
  );

  // Logout function
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  // Delete contact
  Future<void> _deleteContact(String docId) async {
    try {
      await contactsRef.doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contact deleted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Confirm before deleting
  Future<void> _confirmAndDelete(String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete contact?'),
        content: const Text(
          'This will permanently delete the contact message.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteContact(docId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color.fromARGB(177, 8, 46, 92),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 90,
                    child: Lottie.asset("assets/AdminPanel.json", repeat: true),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Admin Panel',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Admin Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminDashboard()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('User Management'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag),
              title: Text('Product Management'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddProductScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.list_alt),
              title: Text('Product List Management'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductListScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Admin Orders Page'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminOrdersPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.contact_mail),
              title: Text('Contact List'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ContactUsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Try-On Sessions'),
              onTap: () {},
            ),
            Divider(),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text(
          'Contact Us Messages',
          style: TextStyle(color: Colors.white), // ✅ Text color white
        ),
        backgroundColor: const Color.fromARGB(177, 8, 46, 92),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: contactsRef.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No contact messages yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name'] ?? '';
              final email = data['email'] ?? '';
              final message = data['message'] ?? '';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name: $name',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('Email: $email'),
                      const SizedBox(height: 6),
                      Text('Message: $message'),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmAndDelete(doc.id),
                        ),
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
