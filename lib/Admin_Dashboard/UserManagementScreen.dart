import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:virtualmakeupapp/Admin_Dashboard/AddProductScreen.dart';
import 'package:virtualmakeupapp/Admin_Dashboard/AdminDashboard.dart';
import 'package:virtualmakeupapp/Admin_Dashboard/AdminOrdersPage.dart';
import 'package:virtualmakeupapp/Admin_Dashboard/ContactUsScreen.dart';
import 'package:virtualmakeupapp/Admin_Dashboard/ProductListScreen.dart';

// UserManagementScreen
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final CollectionReference usersRef = FirebaseFirestore.instance.collection(
    'users',
  );

  // Dummy logout function, replace with your actual function
  void logout() {
    print("Logout clicked");
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
        title: Text("User Management", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(177, 8, 46, 92),
        iconTheme: IconThemeData(color: Colors.white),
      ), // <-- Drawer added here
      body: StreamBuilder<QuerySnapshot>(
        stream: usersRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          return LayoutBuilder(
            builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 600;

              if (isMobile) {
                // Mobile: Card layout
                return ListView.builder(
                  padding: EdgeInsets.all(20),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var user = users[index];

                    String name = user['name'] ?? "No Name";
                    String email = user['email'] ?? "No Email";
                    String mobile = user['mobile'] ?? "N/A";
                    String gender = user.data().toString().contains('gender')
                        ? user['gender']
                        : 'other';
                    String status = user.data().toString().contains('status')
                        ? user['status']
                        : 'active';

                    // Ensure Firestore has status field
                    if (!user.data().toString().contains('status')) {
                      usersRef.doc(user.id).update({'status': 'active'});
                    }

                    // Gender Icon
                    IconData genderIcon;
                    if (gender.toLowerCase() == 'male') {
                      genderIcon = Icons.male;
                    } else if (gender.toLowerCase() == 'female') {
                      genderIcon = Icons.female;
                    } else {
                      genderIcon = Icons.person;
                    }

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      margin: EdgeInsets.only(bottom: 15),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  genderIcon,
                                  size: 50,
                                  color: Colors.deepPurple,
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        email,
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      Text(
                                        mobile,
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    bool confirm = await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text("Delete User"),
                                        content: Text(
                                          "Are you sure you want to delete this user?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: Text(
                                              "Delete",
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm) {
                                      await usersRef.doc(user.id).delete();
                                    }
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Text("Status: "),
                                DropdownButton<String>(
                                  value: status,
                                  items: ['active', 'blocked'].map((value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value.toUpperCase(),
                                        style: TextStyle(
                                          color: value == 'active'
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (newStatus) async {
                                    setState(() {
                                      status = newStatus!;
                                    });
                                    await usersRef.doc(user.id).update({
                                      'status': newStatus,
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                // Web/Tablet: Table layout
                return SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: DataTable(
                    columnSpacing: 20,
                    columns: [
                      DataColumn(label: Text('Gender')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Mobile')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: users.map((user) {
                      String name = user['name'] ?? "No Name";
                      String email = user['email'] ?? "No Email";
                      String mobile = user['mobile'] ?? "N/A";
                      String gender = user.data().toString().contains('gender')
                          ? user['gender']
                          : 'other';
                      String status = user.data().toString().contains('status')
                          ? user['status']
                          : 'active';

                      // Ensure Firestore has status field
                      if (!user.data().toString().contains('status')) {
                        usersRef.doc(user.id).update({'status': 'active'});
                      }

                      IconData genderIcon;
                      if (gender.toLowerCase() == 'male') {
                        genderIcon = Icons.male;
                      } else if (gender.toLowerCase() == 'female') {
                        genderIcon = Icons.female;
                      } else {
                        genderIcon = Icons.person;
                      }

                      return DataRow(
                        cells: [
                          DataCell(Icon(genderIcon, color: Colors.deepPurple)),
                          DataCell(Text(name)),
                          DataCell(Text(email)),
                          DataCell(Text(mobile)),
                          DataCell(
                            DropdownButton<String>(
                              value: status,
                              items: ['active', 'blocked'].map((value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value.toUpperCase(),
                                    style: TextStyle(
                                      color: value == 'active'
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newStatus) async {
                                setState(() {
                                  status = newStatus!;
                                });
                                await usersRef.doc(user.id).update({
                                  'status': newStatus,
                                });
                              },
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                bool confirm = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Delete User"),
                                    content: Text(
                                      "Are you sure you want to delete this user?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text(
                                          "Delete",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm) {
                                  await usersRef.doc(user.id).delete();
                                }
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
