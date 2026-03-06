import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:virtualmakeupapp/Admin_Dashboard/AddProductScreen.dart';
import 'package:virtualmakeupapp/Admin_Dashboard/AdminDashboard.dart';
import 'package:virtualmakeupapp/Admin_Dashboard/AdminOrdersPage.dart';
import 'package:virtualmakeupapp/Admin_Dashboard/ContactUsScreen.dart';
import 'package:virtualmakeupapp/Admin_Dashboard/EditProductScreen.dart';
import 'package:virtualmakeupapp/Admin_Dashboard/UserManagementScreen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final CollectionReference productsRef = FirebaseFirestore.instance.collection(
    'products',
  );

  Future<void> _deleteProduct(String docId) async {
    try {
      await productsRef.doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product deleted'),
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

  Future<void> _confirmAndDelete(String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete product?'),
        content: Text(
          'This will permanently delete the product from the database.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteProduct(docId);
    }
  }

  void _navigateToEdit(DocumentSnapshot doc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(productDoc: doc),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isWide = width >= 700;

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
        title: Text('Products', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(177, 8, 46, 92),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: productsRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            );

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty)
            return Center(
              child: Text(
                'No products yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            );

          // WEB / TABLE VIEW
          if (isWide) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: width),
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    Colors.deepPurple.shade50,
                  ),
                  columns: const [
                    DataColumn(label: Text('Image')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Section')),
                    DataColumn(label: Text('Category / Shade')),
                    DataColumn(label: Text('Price')),
                    DataColumn(label: Text('Stock')), // ✅ stock
                    DataColumn(label: Text('Sold')), // ✅ sold
                    DataColumn(label: Text('Edit')),
                    DataColumn(label: Text('Delete')),
                  ],
                  rows: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final images =
                        (data['images'] as List<dynamic>?)?.cast<String>() ??
                        [];
                    final firstImage = images.isNotEmpty ? images[0] : null;
                    final section = (data['section'] ?? '').toString();
                    final category = section == 'Makeup'
                        ? (data['makeupCategory'] ?? '')
                        : section == 'Hairstyle'
                        ? (data['hairCategory'] ?? '')
                        : (data['frameType'] ?? '');
                    final stock = data['stock'] ?? 0;
                    final sold = data['sold'] ?? 0;

                    return DataRow(
                      cells: [
                        DataCell(
                          firstImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    firstImage,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.grey.shade200,
                                  child: Icon(Icons.image),
                                ),
                        ),
                        DataCell(Text(data['name'] ?? '')),
                        DataCell(Text(section)),
                        DataCell(Text(category.toString())),
                        DataCell(Text((data['price'] ?? 0).toString())),
                        DataCell(Text(stock.toString())), // ✅ stock
                        DataCell(Text(sold.toString())), // ✅ sold
                        DataCell(
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _navigateToEdit(doc),
                            tooltip: 'Edit',
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmAndDelete(doc.id),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          }

          // MOBILE / CARD VIEW
          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final images =
                  (data['images'] as List<dynamic>?)?.cast<String>() ?? [];
              final firstImage = images.isNotEmpty ? images[0] : null;
              final section = (data['section'] ?? '').toString();
              final category = section == 'Makeup'
                  ? (data['makeupCategory'] ?? '')
                  : section == 'Hairstyle'
                  ? (data['hairCategory'] ?? '')
                  : (data['frameType'] ?? '');
              final stock = data['stock'] ?? 0;
              final sold = data['sold'] ?? 0;

              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: firstImage != null
                            ? Image.network(
                                firstImage,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 90,
                                  height: 90,
                                  color: Colors.grey[200],
                                  child: Icon(Icons.broken_image),
                                ),
                              )
                            : Container(
                                width: 90,
                                height: 90,
                                color: Colors.grey[200],
                                child: Icon(Icons.image),
                              ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name'] ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Section: $section',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Category: $category',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Price: PKR ${data['price'] ?? 0}',
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4),
                            // ✅ Stock & Sold
                            Row(
                              children: [
                                Text(
                                  'Stock: $stock',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: stock == 0
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Sold: $sold',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _navigateToEdit(doc),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmAndDelete(doc.id),
                            tooltip: 'Delete',
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
