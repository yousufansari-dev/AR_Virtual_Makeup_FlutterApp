import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'package:flutter/foundation.dart';
import 'package:virtualmakeupapp/Admin_Dashboard/AdminDashboard.dart';
import 'package:virtualmakeupapp/Admin_Dashboard/AdminOrdersPage.dart';
import 'package:virtualmakeupapp/Admin_Dashboard/ContactUsScreen.dart';
import 'package:virtualmakeupapp/Admin_Dashboard/ProductListScreen.dart';
import 'package:virtualmakeupapp/Admin_Dashboard/UserManagementScreen.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  String? customShade;
  final _formKey = GlobalKey<FormState>();
  final CollectionReference productsRef = FirebaseFirestore.instance.collection(
    'products',
  );

  // Controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController frameTypeController = TextEditingController();
  TextEditingController customShadeController = TextEditingController();
  TextEditingController stockController =
      TextEditingController(); // ✅ NEW: stock

  // Images
  List<File> selectedImages = [];
  List<Uint8List> webImages = [];
  List<String> uploadedUrls = [];

  // Section & Categories
  String section = "Makeup";
  String makeupCategory = "All";
  String hairCategory = "Short";

  // Cloudinary
  final String cloudName = "dqyfeznaf";
  final String uploadPreset = "Virtual_Makeup_App";

  // Pick multiple images
  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.length > 4) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("You can select up to 4 images")));
      return;
    }

    if (kIsWeb) {
      webImages.clear();
      for (var img in images) {
        Uint8List bytes = await img.readAsBytes();
        webImages.add(bytes);
      }
    } else {
      selectedImages = images.map((img) => File(img.path)).toList();
    }

    setState(() {});
  }

  // Upload image to Cloudinary
  Future<String?> uploadImage(dynamic image) async {
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    var request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset;

    if (kIsWeb) {
      request.files.add(
        http.MultipartFile.fromBytes('file', image, filename: "upload.jpg"),
      );
    } else {
      request.files.add(await http.MultipartFile.fromPath('file', image.path));
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      final res = await http.Response.fromStream(response);
      return json.decode(res.body)['secure_url'];
    }
    return null;
  }

  // Save product
  Future<void> saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    // IMAGE VALIDATION
    if (kIsWeb && webImages.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please select at least 1 image")));
      return;
    }
    if (!kIsWeb && selectedImages.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please select at least 1 image")));
      return;
    }

    // UPLOAD IMAGES
    uploadedUrls.clear();

    if (kIsWeb) {
      for (var img in webImages) {
        final url = await uploadImage(img);
        if (url != null) uploadedUrls.add(url);
      }
    } else {
      for (var img in selectedImages) {
        final url = await uploadImage(img);
        if (url != null) uploadedUrls.add(url);
      }
    }

    // SAVE FIRESTORE
    await productsRef.add({
      "section": section,
      "name": nameController.text,
      "brand": brandController.text,
      "price": double.tryParse(priceController.text) ?? 0.0,
      "description": descriptionController.text,
      "category": section == "Makeup"
          ? makeupCategory.toLowerCase()
          : section == "Hairstyle"
          ? "hair"
          : "glasses",
      "makeupCategory": section == "Makeup"
          ? ((customShade != null && customShade!.isNotEmpty)
                ? customShade
                : makeupCategory)
          : "",
      "hairCategory": section == "Hairstyle" ? hairCategory : "",
      "frameType": section == "Glasses" ? frameTypeController.text : "",
      "images": uploadedUrls,
      "stock": int.tryParse(stockController.text) ?? 0, // ✅ STOCK
      "sold": 0, // ✅ SOLD
      "createdAt": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Product Added Successfully")));

    // CLEAR FIELDS
    nameController.clear();
    brandController.clear();
    priceController.clear();
    descriptionController.clear();
    frameTypeController.clear();
    customShadeController.clear();
    stockController.clear(); // ✅ clear stock
    customShade = "";

    setState(() {
      selectedImages = [];
      webImages = [];
      uploadedUrls = [];
      makeupCategory = "All";
      customShade = "";
    });
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
        title: Text("Add Product", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(177, 8, 46, 92),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SECTION DROPDOWN
              DropdownButtonFormField(
                initialValue: section,
                decoration: InputDecoration(
                  labelText: "Select Section",
                  border: OutlineInputBorder(),
                ),
                items: ["Makeup", "Hairstyle", "Glasses"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    section = val!;
                  });
                },
              ),
              SizedBox(height: 20),

              // PRODUCT NAME
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Product Name",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Enter product name" : null,
              ),
              SizedBox(height: 20),

              // BRAND NAME
              TextFormField(
                controller: brandController,
                decoration: InputDecoration(
                  labelText: "Brand Name",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Enter brand name" : null,
              ),
              SizedBox(height: 20),

              // STOCK
              TextFormField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Stock Quantity",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Enter stock quantity" : null,
              ),
              SizedBox(height: 20),

              if (section == "Makeup") ...[
                DropdownButtonFormField<String>(
                  initialValue: makeupCategory,
                  decoration: InputDecoration(
                    labelText: "Select Makeup Category",
                    border: OutlineInputBorder(),
                  ),
                  items: ["All", "Lipsticks", "Foundation", "Blush"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => makeupCategory = v!),
                ),
                SizedBox(height: 20),
                // CUSTOM SHADE
                TextFormField(
                  controller: customShadeController,
                  decoration: InputDecoration(
                    labelText: "Add Custom Shade (Optional)",
                    border: OutlineInputBorder(),
                    hintText: "Enter shade name",
                  ),
                  onChanged: (value) {
                    setState(() {
                      customShade = value;
                    });
                  },
                ),
                SizedBox(height: 20),
              ],

              if (section == "Hairstyle")
                DropdownButtonFormField(
                  initialValue: hairCategory,
                  decoration: InputDecoration(
                    labelText: "Hair Wig Category",
                    border: OutlineInputBorder(),
                  ),
                  items: ["Short", "Medium", "Long"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => hairCategory = v!),
                ),
              SizedBox(height: 20),

              if (section == "Glasses")
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Frame Type",
                    border: OutlineInputBorder(),
                  ),
                  items:
                      [
                            "Full Rim",
                            "Half Rim",
                            "Rimless",
                            "Round Frame",
                            "Cat Eye",
                          ]
                          .map(
                            (x) => DropdownMenuItem(value: x, child: Text(x)),
                          )
                          .toList(),
                  onChanged: (val) {
                    frameTypeController.text = val!;
                  },
                  validator: (v) => section == "Glasses" && v == null
                      ? "Select frame type"
                      : null,
                ),
              SizedBox(height: 20),

              // DESCRIPTION
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              // PRICE
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Price",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Enter price" : null,
              ),
              SizedBox(height: 20),

              // IMAGE PICKER
              Row(
                children: [
                  ElevatedButton(
                    onPressed: pickImages,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: Text(
                      "Select Images",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 10),
                  (kIsWeb ? webImages.isNotEmpty : selectedImages.isNotEmpty)
                      ? Expanded(
                          child: SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: kIsWeb
                                  ? webImages.length
                                  : selectedImages.length,
                              itemBuilder: (c, i) => Padding(
                                padding: EdgeInsets.all(5),
                                child: kIsWeb
                                    ? Image.memory(
                                        webImages[i],
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        selectedImages[i],
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                        )
                      : Text("No images selected"),
                ],
              ),
              SizedBox(height: 30),

              // SAVE BUTTON
              Center(
                child: ElevatedButton(
                  onPressed: saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text(
                    "Add Product",
                    style: TextStyle(color: Colors.white),
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
