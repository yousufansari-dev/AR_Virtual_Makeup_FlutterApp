import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryPage extends StatelessWidget {
  final String categoryName;

  const CategoryPage({super.key, required this.categoryName});

  Stream<QuerySnapshot> _categoryProducts() {
    return FirebaseFirestore.instance
        .collection("products")
        .where("category", isEqualTo: categoryName.toLowerCase())
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(177, 8, 46, 92),
        title: Text("$categoryName Products"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _categoryProducts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(177, 8, 46, 92),
              ),
            );
          }

          var products = snapshot.data!.docs;

          if (products.isEmpty) {
            return Center(child: Text("No products found in $categoryName"));
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              var data = products[index].data() as Map<String, dynamic>;

              return ListTile(
                leading: Image.network(
                  (data["images"] as List).isNotEmpty
                      ? data["images"][0]
                      : "https://via.placeholder.com/150",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(data["name"] ?? "No Name"),
                subtitle: Text("PKR ${data["price"]}"),
              );
            },
          );
        },
      ),
    );
  }
}
