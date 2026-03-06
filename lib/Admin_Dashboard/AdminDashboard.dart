import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:virtualmakeupapp/Admin_Dashboard/AddProductScreen.dart';
import 'package:virtualmakeupapp/Admin_Dashboard/AdminOrdersPage.dart';
import 'package:virtualmakeupapp/Admin_Dashboard/ContactUsScreen.dart';
import 'package:virtualmakeupapp/Admin_Dashboard/ProductListScreen.dart';
import 'package:virtualmakeupapp/Admin_Dashboard/UserManagementScreen.dart';
import 'package:virtualmakeupapp/Login-Signup/LoginScreen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int totalUsers = 0;
  int totalProducts = 0;
  int ordersPending = 0;
  int ordersApproved = 0;
  int totalContacts = 0;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      // Users
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      totalUsers = usersSnapshot.docs.length;

      // Contact messages
      final contactsSnapshot = await FirebaseFirestore.instance
          .collection('contact_messages')
          .get();
      totalContacts = contactsSnapshot.docs.length;

      // Products
      final productsSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();
      totalProducts = productsSnapshot.docs.length;

      // Orders
      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .get();
      ordersPending = ordersSnapshot.docs
          .where(
            (doc) =>
                ((doc.data() as Map<String, dynamic>?)?['status'] ?? '') ==
                'pending',
          )
          .length;
      ordersApproved = ordersSnapshot.docs
          .where(
            (doc) =>
                ((doc.data() as Map<String, dynamic>?)?['status'] ?? '') ==
                'approved',
          )
          .length;

      // Try-On sessions

      setState(() {});
    } catch (e) {
      print("Error fetching dashboard data: $e");
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(177, 8, 46, 92),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
            tooltip: "Logout",
          ),
        ],
      ),
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
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: logout,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 800
                ? 3
                : constraints.maxWidth > 600
                ? 2
                : 1;

            return GridView.builder(
              itemCount: 5, // ❗ 6 → 5
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.5,
              ),

              itemBuilder: (context, index) {
                List<Widget> cards = [
                  _summaryCard(
                    title: "Total Users",
                    count: totalUsers,
                    icon: Icons.person,
                    color: Colors.orange,
                  ),
                  _summaryCard(
                    title: "Total Products",
                    count: totalProducts,
                    icon: Icons.shopping_bag,
                    color: Colors.green,
                  ),
                  _summaryCard(
                    title: "Orders Pending",
                    count: ordersPending,
                    icon: Icons.pending_actions,
                    color: Colors.red,
                  ),
                  _summaryCard(
                    title: "Orders Approved",
                    count: ordersApproved,
                    icon: Icons.check_circle,
                    color: Colors.blue,
                  ),
                  _summaryCard(
                    title: "Contact Us",
                    count: totalContacts,
                    icon: Icons.contact_mail,
                    color: Colors.teal,
                  ),
                ];

                return cards[index];
              },
            );
          },
        ),
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 15),
            Text(
              "${count ?? 0}",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
