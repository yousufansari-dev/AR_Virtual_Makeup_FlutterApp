import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtualmakeupapp/Main_Screen/OrderSuccessScreen.dart';

class CheckoutScreen extends StatefulWidget {
  final String userId;
  final List<Map<String, dynamic>> cartProducts;
  final Map<String, int> quantities;

  const CheckoutScreen({
    super.key,
    required this.userId,
    required this.cartProducts,
    required this.quantities,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController paymentDetailsController = TextEditingController();

  String? userName;
  String? userEmail;
  String? selectedCity;
  String? selectedArea;
  String? selectedDate;
  String? selectedPayment;

  Map<String, int> quantities = {};

  double subtotal = 0;
  double deliveryCharge = 500;
  double tax = 1000;
  double totalAmount = 0;

  // ⭐ Updated Lists (5 options each)
  List<String> cities = [
    "Karachi",
    "Lahore",
    "Islamabad",
    "Rawalpindi",
    "Multan",
  ];

  Map<String, List<String>> areas = {
    "Karachi": ["Clifton", "Gulshan", "Korangi", "Nazimabad", "Malir"],
    "Lahore": ["DHA", "Gulberg", "Model Town", "Johar Town", "Cantt"],
    "Islamabad": ["F-8", "G-10", "I-10", "Blue Area", "F-10"],
    "Rawalpindi": [
      "Saddar",
      "Peshawar Road",
      "Satellite Town",
      "Bahria Town",
      "Scheme 3",
    ],
    "Multan": [
      "Cantt",
      "Shah Rukn-e-Alam",
      "Bosan Road",
      "Gulgasht",
      "Ghanta Ghar",
    ],
  };

  List<String> deliveryDates = [
    "Tomorrow",
    "Day after Tomorrow",
    "3 days later",
    "This Week",
    "Next Week",
  ];

  List<String> paymentMethods = [
    "Bank Account",
    "Easypaisa",
    "Cash on Delivery",
  ];

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
    quantities = Map<String, int>.from(widget.quantities);
    calculateTotal();
  }

  Future<void> fetchUserDetails() async {
    var doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    if (doc.exists) {
      setState(() {
        userName = doc['name'];
        userEmail = doc['email'];
      });
    }
  }

  void calculateTotal() {
    double total = 0;
    for (var product in widget.cartProducts) {
      int qty = quantities[product['id']] ?? 1;
      total += (product['price'] ?? 0) * qty;
    }
    setState(() {
      subtotal = total;
      totalAmount = subtotal + deliveryCharge + tax;
    });
  }

  Future<void> updateStockAndSold() async {
    final firestore = FirebaseFirestore.instance;

    try {
      await firestore.runTransaction((transaction) async {
        for (var product in widget.cartProducts) {
          final productId = product['id'];
          final qty = quantities[productId] ?? 1;

          final docRef = firestore.collection("products").doc(productId);

          final snapshot = await transaction.get(docRef);

          if (!snapshot.exists) {
            throw Exception("Product ${product['name']} no longer exists");
          }

          final data = snapshot.data() as Map<String, dynamic>;
          int currentStock = (data['stock'] is int) ? data['stock'] : 0;
          int currentSold = (data['sold'] is int) ? data['sold'] : 0;

          if (qty > currentStock) {
            throw Exception(
              "Only $currentStock items left for ${product['name']}. Please update your cart.",
            );
          }

          transaction.update(docRef, {
            "stock": currentStock - qty,
            "sold": currentSold + qty,
          });
        }
      });
    } catch (e) {
      // Close loading dialog if open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );

      // Re-throw to prevent order placement
      throw e;
    }
  }

  Future<void> placeOrder() async {
    if (!_formKey.currentState!.validate() ||
        selectedCity == null ||
        selectedArea == null ||
        selectedDate == null ||
        selectedPayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    // ⭐ Show Lottie Loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Lottie.asset("assets/loader.json", width: 150, height: 150),
      ),
    );

    try {
      await updateStockAndSold();

      List<Map<String, dynamic>> orderItems = [];
      for (var product in widget.cartProducts) {
        orderItems.add({
          "productId": product['id'],
          "name": product['name'],
          "price": product['price'] ?? 0,
          "quantity": quantities[product['id']] ?? 1,
          "image": product['image'] ?? "",
          "brand": product['brand'] ?? "",
          "shades": product['shades'] ?? [],
        });
      }

      DocumentReference orderRef = await FirebaseFirestore.instance
          .collection('orders')
          .add({
            "userId": widget.userId,
            "userName": userName,
            "userEmail": userEmail,
            "phone": phoneController.text,
            "address": addressController.text,
            "city": selectedCity,
            "area": selectedArea,
            "deliveryDate": selectedDate,
            "paymentMethod": selectedPayment,
            "paymentDetails": selectedPayment == "Cash on Delivery"
                ? "Pay on Delivery"
                : paymentDetailsController.text,
            "items": orderItems,
            "subtotal": subtotal,
            "deliveryCharge": deliveryCharge,
            "tax": tax,
            "totalAmount": totalAmount,
            "status": "completed",
            "timestamp": FieldValue.serverTimestamp(),
          });

      Navigator.pop(context);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              OrderSuccessScreen(orderId: orderRef.id, userName: userName!),
        ),
      );
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Order Failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Checkout",
          style: TextStyle(color: Colors.white), // 👈 White text
        ),
        backgroundColor: Color.fromARGB(177, 8, 46, 92),
      ),

      body: userName == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // 🧍 Name (read only)
                          TextFormField(
                            initialValue: userName,
                            decoration: InputDecoration(
                              labelText: "Name",
                              border: OutlineInputBorder(),
                            ),
                            enabled: false,
                          ),
                          SizedBox(height: 8),

                          // 📧 Email (read only)
                          TextFormField(
                            initialValue: userEmail,
                            decoration: InputDecoration(
                              labelText: "Email",
                              border: OutlineInputBorder(),
                            ),
                            enabled: false,
                          ),
                          SizedBox(height: 8),

                          // 📱 Phone with restriction 11 digits
                          TextFormField(
                            controller: phoneController,
                            decoration: InputDecoration(
                              labelText: "Phone Number",
                              hintText: "03XXXXXXXXX",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 11,
                            validator: (value) {
                              if (value == null || value.length != 11) {
                                return "Enter valid 11-digit phone number";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 8),

                          // 📍 Address
                          TextFormField(
                            controller: addressController,
                            decoration: InputDecoration(
                              labelText: "Delivery Address",
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? "Address required" : null,
                          ),
                          SizedBox(height: 8),

                          // 🏙 City
                          DropdownButtonFormField<String>(
                            initialValue: selectedCity,
                            items: cities
                                .map(
                                  (city) => DropdownMenuItem(
                                    value: city,
                                    child: Text(city),
                                  ),
                                )
                                .toList(),
                            hint: Text("Select City"),
                            onChanged: (value) {
                              setState(() {
                                selectedCity = value;
                                selectedArea = null;
                              });
                            },
                            validator: (value) =>
                                value == null ? "City required" : null,
                          ),
                          SizedBox(height: 8),

                          // 📌 Area
                          DropdownButtonFormField<String>(
                            initialValue: selectedArea,
                            items: selectedCity == null
                                ? []
                                : areas[selectedCity]!
                                      .map(
                                        (area) => DropdownMenuItem(
                                          value: area,
                                          child: Text(area),
                                        ),
                                      )
                                      .toList(),
                            hint: Text("Select Area"),
                            onChanged: (value) {
                              setState(() {
                                selectedArea = value;
                              });
                            },
                            validator: (value) =>
                                value == null ? "Area required" : null,
                          ),
                          SizedBox(height: 8),

                          // 🚚 Delivery Date
                          DropdownButtonFormField<String>(
                            initialValue: selectedDate,
                            items: deliveryDates
                                .map(
                                  (date) => DropdownMenuItem(
                                    value: date,
                                    child: Text(date),
                                  ),
                                )
                                .toList(),
                            hint: Text("Select Delivery Date"),
                            onChanged: (value) {
                              setState(() {
                                selectedDate = value;
                              });
                            },
                            validator: (value) =>
                                value == null ? "Delivery date required" : null,
                          ),
                          SizedBox(height: 8),

                          // 💳 Payment Method
                          DropdownButtonFormField<String>(
                            initialValue: selectedPayment,
                            items: paymentMethods
                                .map(
                                  (method) => DropdownMenuItem(
                                    value: method,
                                    child: Text(method),
                                  ),
                                )
                                .toList(),
                            hint: Text("Select Payment Method"),
                            onChanged: (value) {
                              setState(() {
                                selectedPayment = value;
                              });
                            },
                            validator: (value) => value == null
                                ? "Payment method required"
                                : null,
                          ),
                          SizedBox(height: 8),

                          // 🧾 Payment Input Depending on Method
                          // Easypaisa Input
                          if (selectedPayment == "Easypaisa")
                            TextFormField(
                              controller: paymentDetailsController,
                              decoration: InputDecoration(
                                labelText: "Easypaisa Number",
                                hintText: "03XXXXXXXXX",
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 11,
                              validator: (value) {
                                if (selectedPayment == "Easypaisa" &&
                                    (value == null || value.length != 11)) {
                                  return "Enter valid 11-digit Easypaisa number";
                                }
                                return null;
                              },
                            ),

                          // Bank Input
                          if (selectedPayment == "Bank Account")
                            TextFormField(
                              controller: paymentDetailsController,
                              decoration: InputDecoration(
                                labelText: "IBAN Number",
                                hintText: "PKXX-XXXX-XXXX-XXXX",
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (selectedPayment == "Bank Account" &&
                                    (value == null || value.isEmpty)) {
                                  return "Enter valid IBAN number";
                                }
                                return null;
                              },
                            ),

                          // COD — no input required 🔥
                          if (selectedPayment == "Cash on Delivery")
                            Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.money, color: Colors.green),
                                    SizedBox(width: 10),
                                    Text(
                                      "Pay when order arrives",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),
                    Divider(),
                    Text(
                      "Order Summary",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // 🛒 Show Products Summary
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: widget.cartProducts.length,
                      itemBuilder: (context, index) {
                        var product = widget.cartProducts[index];
                        var shades =
                            (product['shades'] as List?)?.cast<String>() ?? [];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child:
                                (product['image'] != null &&
                                    product['image'].toString().isNotEmpty &&
                                    product['image'].toString().startsWith(
                                      'http',
                                    ))
                                ? Image.network(
                                    product['image'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        "assets/images/no_image.png",
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    "assets/images/no_image.png",
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                          ),

                          title: Text(product['name']),
                          subtitle: Text(
                            "Shade: ${shades.join(", ")} | Qty: ${quantities[product['id']]}",
                          ),
                          trailing: Text(
                            "PKR ${(product['price'] ?? 0) * (quantities[product['id']] ?? 1)}",
                          ),
                        );
                      },
                    ),

                    ListTile(
                      title: Text("Subtotal"),
                      trailing: Text("PKR $subtotal"),
                    ),
                    ListTile(
                      title: Text("Delivery Charge"),
                      trailing: Text("PKR $deliveryCharge"),
                    ),
                    ListTile(
                      title: Text("Tax / GST"),
                      trailing: Text("PKR $tax"),
                    ),

                    Divider(),
                    ListTile(
                      title: Text(
                        "Total Amount",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        "PKR $totalAmount",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.pink,
                        ),
                      ),
                    ),

                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(177, 8, 46, 92),
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Place Order",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
