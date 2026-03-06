import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtualmakeupapp/Main_Screen/CheckoutScreen.dart';
// Make sure this is imported

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartProducts;

  const CartScreen({
    super.key,
    required this.cartProducts,
    required List<String> cartItems,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> cartProducts = [];
  Map<String, int> quantities = {}; // store quantity per product id
  Map<String, int> stockInfo = {}; // store current stock per product id
  double totalAmount = 0;

  @override
  void initState() {
    super.initState();
    cartProducts = widget.cartProducts;

    // Initialize quantities
    for (var product in widget.cartProducts) {
      quantities[product['id']] = 1;
    }

    calculateTotal();
    fetchStockInfo(); // Fetch current stock information
  }

  // Fetch current stock information for all cart products
  void fetchStockInfo() async {
    for (var product in cartProducts) {
      try {
        DocumentSnapshot productDoc = await FirebaseFirestore.instance
            .collection('products')
            .doc(product['id'])
            .get();
        
        if (productDoc.exists) {
          Map<String, dynamic> productData = productDoc.data() as Map<String, dynamic>;
          int currentStock = productData['stock'] ?? 0;
          
          setState(() {
            stockInfo[product['id']] = currentStock;
            
            // If product is out of stock, adjust quantity to 0 and show warning
            if (currentStock <= 0) {
              quantities[product['id']] = 0;
              
              // Show warning that product is out of stock
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "${productData['name'] ?? 'Product'} is now out of stock and has been removed from your cart.",
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 4),
                  ),
                );
              });
            }
            // If current quantity exceeds available stock, adjust it
            else if ((quantities[product['id']] ?? 1) > currentStock) {
              quantities[product['id']] = currentStock;
              
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Quantity adjusted to available stock ($currentStock) for ${productData['name'] ?? 'product'}.",
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 3),
                  ),
                );
              });
            }
          });
          
          calculateTotal();
        }
      } catch (e) {
        print("Error fetching stock for ${product['id']}: $e");
      }
    }
  }

  void calculateTotal() {
    double total = 0;
    for (var product in cartProducts) {
      int qty = quantities[product['id']] ?? 1;
      if (qty > 0) { // Only include products with quantity > 0
        total += (product['price'] ?? 0) * qty;
      }
    }
    setState(() {
      totalAmount = total;
    });
  }

  void increaseQuantity(String productId) async {
    // Get current stock from Firestore
    try {
      DocumentSnapshot productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();
      
      if (productDoc.exists) {
        Map<String, dynamic> productData = productDoc.data() as Map<String, dynamic>;
        int currentStock = productData['stock'] ?? 0;
        int currentQuantity = quantities[productId] ?? 1;
        
        if (currentQuantity >= currentStock) {
          // Show alert if trying to add more than available stock
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Only $currentStock items available in stock! Cannot add more.",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }
        
        if (currentStock <= 0) {
          // Show alert if product is out of stock
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "${productData['name'] ?? 'Product'} is out of stock!",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }
      }
      
      // If stock is available, increase quantity
      setState(() {
        quantities[productId] = (quantities[productId] ?? 1) + 1;
        calculateTotal();
      });
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error checking stock: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void decreaseQuantity(String productId) {
    setState(() {
      if ((quantities[productId] ?? 1) > 1) {
        quantities[productId] = (quantities[productId] ?? 1) - 1;
        calculateTotal();
      }
    });
  }

  void removeFromCart(String productId) {
    setState(() {
      cartProducts.removeWhere((product) => product['id'] == productId);
      quantities.remove(productId);
      stockInfo.remove(productId);
      calculateTotal();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Product removed from cart"),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter products with quantity > 0
    var activeCartProducts = cartProducts.where((product) => (quantities[product['id']] ?? 0) > 0).toList();
    
    if (activeCartProducts.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Cart"),
          backgroundColor: Color.fromARGB(177, 8, 46, 92),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "No products in cart",
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Get current logged-in user ID
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Cart",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color.fromARGB(177, 8, 46, 92),
        iconTheme: IconThemeData(color: Colors.white), // ← back icon also white
      ),

      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartProducts.where((product) => (quantities[product['id']] ?? 0) > 0).length,
                itemBuilder: (context, index) {
                  // Filter products with quantity > 0
                  var filteredProducts = cartProducts.where((product) => (quantities[product['id']] ?? 0) > 0).toList();
                  
                  if (index >= filteredProducts.length) return SizedBox.shrink();
                  
                  var product = filteredProducts[index];
                  var shades =
                      (product['shades'] as List?)?.cast<String>() ?? [];

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Image.network(
                            product['image'] ?? "",
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'] ?? "",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "Brand: ${product['brand'] ?? ""}",
                                  style: GoogleFonts.nunito(fontSize: 14),
                                ),
                                if (shades.isNotEmpty)
                                  Text(
                                    "Shades: ${shades.join(", ")}",
                                    style: GoogleFonts.nunito(fontSize: 14),
                                  ),
                                SizedBox(height: 4),
                                // Stock Information
                                Text(
                                  "Available Stock: ${stockInfo[product['id']] ?? 'Loading...'}",
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    color: (stockInfo[product['id']] ?? 0) <= 0 
                                        ? Colors.red 
                                        : (stockInfo[product['id']] ?? 0) <= 5 
                                            ? Colors.orange 
                                            : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "PKR ${product['price'] ?? 0}",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () =>
                                            decreaseQuantity(product['id']),
                                        icon: Icon(Icons.remove, color: Colors.red),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          quantities[product['id']].toString(),
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: (stockInfo[product['id']] ?? 0) <= 0 ||
                                                (quantities[product['id']] ?? 1) >= (stockInfo[product['id']] ?? 0)
                                            ? null // Disable if out of stock or quantity equals stock
                                            : () => increaseQuantity(product['id']),
                                        icon: Icon(
                                          Icons.add, 
                                          color: (stockInfo[product['id']] ?? 0) <= 0 ||
                                                 (quantities[product['id']] ?? 1) >= (stockInfo[product['id']] ?? 0)
                                              ? Colors.grey 
                                              : Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Stock warning if quantity is close to limit
                                  if ((stockInfo[product['id']] ?? 0) > 0 && 
                                      (quantities[product['id']] ?? 1) >= (stockInfo[product['id']] ?? 0))
                                    Text(
                                      "Max stock reached",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(width: 8),
                              // Remove button
                              IconButton(
                                onPressed: () => removeFromCart(product['id']),
                                icon: Icon(Icons.delete, color: Colors.red),
                                tooltip: "Remove from cart",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Amount",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "PKR $totalAmount",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.pink,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(177, 8, 46, 92),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: userId == null
                  ? null
                  : () {
                      // Navigate to CheckoutScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutScreen(
                            userId: userId,
                            cartProducts: cartProducts,
                            quantities:
                                quantities, // pass the updated quantities
                          ),
                        ),
                      );
                    },
              child: Text(
                "Checkout",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
