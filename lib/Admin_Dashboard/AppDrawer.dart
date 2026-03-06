import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'UserManagementScreen.dart'; // Import your screen

class AppDrawer extends StatelessWidget {
  final VoidCallback logout;

  const AppDrawer({super.key, required this.logout});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  "assets/AdminPanel.json",
                  height: 100,
                  repeat: true,
                ),
                SizedBox(height: 10),
                Text(
                  'Admin Panel',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('User Management'),
            onTap: () {
              Navigator.pop(context); // Drawer close karne ke liye
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserManagementScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_bag),
            title: Text('Product Management'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.list_alt),
            title: Text('Order Management'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.camera),
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
    );
  }
}
