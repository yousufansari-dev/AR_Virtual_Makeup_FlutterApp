import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtualmakeupapp/Main_Screen/CartScreen.dart';
// import your CartScreen

class WishlistScreen extends StatefulWidget {
  final List<String> wishlist;
  final Function(String, bool) onWishlistChanged;

  const WishlistScreen({
    super.key,
    required this.wishlist,
    required this.onWishlistChanged,
  });

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<String> localWishlist = [];
  List<Map<String, dynamic>> cartProducts = []; // Local cart list

  @override
  void initState() {
    super.initState();
    localWishlist = List.from(widget.wishlist);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wishlist',
          style: TextStyle(
            color: Colors.white, // 🔹 Text white
          ),
        ),
        backgroundColor: const Color.fromARGB(
          177,
          8,
          46,
          92,
        ), // 🔹 Pink background
      ),
      body: localWishlist.isEmpty
          ? Center(child: Text("No products in wishlist"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("products")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var wishlistProducts = snapshot.data!.docs.where((doc) {
                  return localWishlist.contains(doc.id);
                }).toList();

                if (wishlistProducts.isEmpty) {
                  return Center(child: Text("No products found in wishlist"));
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: wishlistProducts.length,
                        itemBuilder: (context, index) {
                          var doc = wishlistProducts[index];
                          var data = doc.data() as Map<String, dynamic>;
                          var productId = doc.id;
                          var image = (data["images"] as List).isNotEmpty
                              ? data["images"][0]
                              : "";
                          var name = data['name'] ?? "";
                          var price = data['price'] ?? 0;
                          var brand = data['brand'] ?? "";
                          var shades =
                              (data['shades'] as List?)?.cast<String>() ?? [];
                          var stock = data['stock'] ?? 0;

                          return Card(
                            margin: EdgeInsets.all(10),
                            child: ListTile(
                              leading: image.isNotEmpty
                                  ? Image.network(
                                      image,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey[300],
                                      child: Icon(
                                        Icons.image,
                                        color: Colors.white,
                                      ),
                                    ),
                              title: Text(name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("PKR $price"),
                                  Text(
                                    "Stock: $stock",
                                    style: TextStyle(
                                      color: stock <= 0 ? Colors.red : Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: stock <= 0 
                                          ? Colors.grey 
                                          : Color.fromARGB(177, 8, 46, 92),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: stock <= 0 ? null : () {
                                      if (stock <= 0) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("$name is out of stock! Please update stock."),
                                            backgroundColor: Colors.red,
                                            duration: Duration(seconds: 3),
                                          ),
                                        );
                                        return;
                                      }

                                      setState(() {
                                        cartProducts.add({
                                          "id": productId,
                                          "name": name,
                                          "image": image,
                                          "price": price,
                                          "brand": brand,
                                          "shades": shades,
                                          "quantity": 1,
                                        });
                                      });

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text("$name added to cart"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },

                                    child: Text(
                                      stock <= 0 ? "Out of Stock" : "Add to Cart",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(Icons.close, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        localWishlist.remove(productId);
                                        widget.onWishlistChanged(
                                          productId,
                                          false,
                                        ); // 🔥 Callback called here
                                      });
                                      
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("$name removed from wishlist"),
                                          backgroundColor: Colors.orange,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // View Cart Button
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(177, 8, 46, 92),
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (cartProducts.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("No products in cart")),
                            );
                            return;
                          }

                          // Navigate to CartScreen with list of products
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CartScreen(
                                cartProducts: cartProducts,
                                cartItems: cartProducts
                                    .map((p) => p["id"].toString())
                                    .toList(),
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "View Cart (${cartProducts.length})",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
