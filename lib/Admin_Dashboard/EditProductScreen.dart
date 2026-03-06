import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProductScreen extends StatefulWidget {
  final DocumentSnapshot productDoc;

  const EditProductScreen({super.key, required this.productDoc});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController brandController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController stockController;

  List<String> existingImages = [];
  List<XFile> newImages = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final data = widget.productDoc.data() as Map<String, dynamic>;
    nameController = TextEditingController(text: data['name'] ?? '');
    brandController = TextEditingController(text: data['brand'] ?? '');
    descriptionController = TextEditingController(
      text: data['description'] ?? '',
    );
    priceController = TextEditingController(
      text: (data['price'] ?? '').toString(),
    );
    stockController = TextEditingController(
      text: (data['stock'] ?? 0).toString(),
    );
    // Add listener to update stock status indicator
    stockController.addListener(() {
      setState(() {});
    });
    existingImages = (data['images'] as List<dynamic>?)?.cast<String>() ?? [];
  }

  @override
  void dispose() {
    nameController.dispose();
    brandController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    stockController.dispose();
    super.dispose();
  }

  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        // Remove all old images when new images are picked
        existingImages.clear();
        newImages = pickedFiles;
      });
    }
  }

  Future<String> uploadImageToCloudinary(XFile pickedFile) async {
    const cloudName = 'dqyfeznaf';
    const uploadPreset = 'Virtual_Makeup_App';

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset;

    if (kIsWeb) {
      final bytes = await pickedFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: 'image.jpg'),
      );
    } else {
      request.files.add(
        await http.MultipartFile.fromPath('file', pickedFile.path),
      );
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final data = json.decode(resStr);
      return data['secure_url'];
    } else {
      throw Exception('Cloudinary upload failed: ${response.statusCode}');
    }
  }

  Future<void> saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      List<String> uploadedUrls = [];

      for (var image in newImages) {
        String url = await uploadImageToCloudinary(image);
        uploadedUrls.add(url);
      }

      // Only save the new uploaded images (old images are replaced)
      List<String> finalImages = [...uploadedUrls];

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productDoc.id)
          .update({
            'name': nameController.text.trim(),
            'brand': brandController.text.trim(),
            'description': descriptionController.text.trim(),
            'price': double.tryParse(priceController.text.trim()) ?? 0,
            'stock': int.tryParse(stockController.text.trim()) ?? 0,
            'images': finalImages,
          });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product updated successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Update failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void removeExistingImage(int index) {
    setState(() {
      existingImages.removeAt(index);
    });
  }

  void removeNewImage(int index) {
    setState(() {
      newImages.removeAt(index);
    });
  }

  // Stock status helper methods
  Color _getStockStatusColor() {
    final stock = int.tryParse(stockController.text) ?? 0;
    if (stock == 0) return Colors.red;
    if (stock <= 5) return Colors.orange;
    return Colors.green;
  }

  IconData _getStockStatusIcon() {
    final stock = int.tryParse(stockController.text) ?? 0;
    if (stock == 0) return Icons.error;
    if (stock <= 5) return Icons.warning;
    return Icons.check_circle;
  }

  String _getStockStatusText() {
    final stock = int.tryParse(stockController.text) ?? 0;
    if (stock == 0) return 'Out of Stock - Product will not be available for purchase';
    if (stock <= 5) return 'Low Stock - Only $stock items remaining';
    return 'In Stock - $stock items available';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(177, 8, 46, 92),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Product Name'),
                      validator: (val) => val == null || val.isEmpty
                          ? 'Enter product name'
                          : null,
                    ),
                    TextFormField(
                      controller: brandController,
                      decoration: InputDecoration(labelText: 'Brand Name'),
                      validator: (val) => val == null || val.isEmpty
                          ? 'Enter brand name'
                          : null,
                    ),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    TextFormField(
                      controller: priceController,
                      decoration: InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Enter price' : null,
                    ),
                    TextFormField(
                      controller: stockController,
                      decoration: InputDecoration(
                        labelText: 'Stock Quantity',
                        hintText: 'Enter available stock quantity',
                        suffixIcon: Icon(Icons.inventory),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Enter stock quantity';
                        }
                        final stock = int.tryParse(val);
                        if (stock == null || stock < 0) {
                          return 'Enter valid stock quantity (0 or more)';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 8),
                    // Stock Status Indicator
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getStockStatusColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _getStockStatusColor()),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getStockStatusIcon(),
                            color: _getStockStatusColor(),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getStockStatusText(),
                              style: TextStyle(
                                color: _getStockStatusColor(),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    if (existingImages.isNotEmpty) ...[
                      Text(
                        'Existing Images',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: List.generate(
                          existingImages.length,
                          (index) => Stack(
                            children: [
                              Image.network(
                                existingImages[index],
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () => removeExistingImage(index),
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.red,
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                    ],
                    Text(
                      'Add New Images',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ...newImages.map(
                          (file) => Stack(
                            children: [
                              kIsWeb
                                  ? Image.network(
                                      file.path,
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(file.path),
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                    ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () =>
                                      removeNewImage(newImages.indexOf(file)),
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.red,
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: pickImages,
                          child: Container(
                            width: 90,
                            height: 90,
                            color: Colors.grey[300],
                            child: Icon(Icons.add_a_photo),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          'Update Product',
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
