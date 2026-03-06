import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:virtualmakeupapp/Category_Pages/chatbot.dart';

class ComparisonToolScreen extends StatefulWidget {
  const ComparisonToolScreen({super.key});

  @override
  State<ComparisonToolScreen> createState() => _ComparisonToolScreenState();
}

class _ComparisonToolScreenState extends State<ComparisonToolScreen> {
  bool _isSideBySide = true;

  // 10 products using asset images
  final List<Map<String, dynamic>> products = [
    {
      "name": "Maybelline Lipstick",
      "image": "assets/images/lipstick.png",
      "brand": "Maybelline",
      "rating": 4.5,
      "price": "\$15",
    },
    {
      "name": "L'Oreal Foundation",
      "image": "assets/images/foundation.png",
      "brand": "L'Oreal",
      "rating": 4.7,
      "price": "\$25",
    },
    {
      "name": "MAC Lipstick",
      "image": "assets/images/MACLipstick.png",
      "brand": "MAC",
      "rating": 4.8,
      "price": "\$20",
    },
    {
      "name": "NYX Lip Gloss",
      "image": "assets/images/NYXLipGloss.png",
      "brand": "NYX",
      "rating": 4.3,
      "price": "\$12",
    },
    {
      "name": "Fenty Beauty Foundation",
      "image": "assets/images/FentyBeautyFoundation.png",
      "brand": "Fenty Beauty",
      "rating": 4.9,
      "price": "\$30",
    },
    {
      "name": "Revlon Matte Lipstick",
      "image": "assets/images/RevlonMatteLipstick.png",
      "brand": "Revlon",
      "rating": 4.4,
      "price": "\$14",
    },
    {
      "name": "Clinique Foundation",
      "image": "assets/images/CliniqueFoundation.png",
      "brand": "Clinique",
      "rating": 4.6,
      "price": "\$28",
    },
    {
      "name": "Urban Decay Lipstick",
      "image": "assets/images/UrbanDecayLipstick.png",
      "brand": "Urban Decay",
      "rating": 4.7,
      "price": "\$22",
    },
    {
      "name": "Dior Lipstick",
      "image": "assets/images/DiorLipstick.png",
      "brand": "Dior",
      "rating": 4.8,
      "price": "\$35",
    },
    {
      "name": "Estee Lauder Foundation",
      "image": "assets/images/EsteeLauderFoundation.png",
      "brand": "Estee Lauder",
      "rating": 4.9,
      "price": "\$40",
    },
  ];

  Map<String, dynamic>? selectedProduct1;
  Map<String, dynamic>? selectedProduct2;

  @override
  void initState() {
    super.initState();
    selectedProduct1 = products[0];
    selectedProduct2 = products[1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Comparison Tool",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(177, 8, 46, 92),
        actions: [
          IconButton(
            icon: Icon(
              _isSideBySide ? Icons.swap_horiz : Icons.view_agenda,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isSideBySide = !_isSideBySide;
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(child: _buildDropdown(1, selectedProduct1!)),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdown(2, selectedProduct2!)),
              ],
            ),
          ),
        ),
      ),

      // *********** FIXED BODY ***********
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _isSideBySide
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.48,
                      child: _buildPhotoCard(selectedProduct1!),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.48,
                      child: _buildPhotoCard(selectedProduct2!),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(child: _buildPhotoCard(selectedProduct1!)),
                  const SizedBox(height: 10),
                  Expanded(child: _buildPhotoCard(selectedProduct2!)),
                ],
              ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(177, 8, 46, 92), // #831843
        child: Text(
          '💄', // Lipstick emoji
          style: TextStyle(fontSize: 24), // make it big enough
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatBotPage()),
          );
        },
      ),
    );
  }

  Widget _buildDropdown(int productNumber, Map<String, dynamic> selected) {
    return DropdownButtonFormField<Map<String, dynamic>>(
      initialValue: selected,
      isExpanded: true, // 👈 VERY IMPORTANT (fix overflow)
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: productNumber == 1 ? "Product 1" : "Product 2",
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: products.map((product) {
        return DropdownMenuItem<Map<String, dynamic>>(
          value: product,
          child: Row(
            children: [
              // 👇 (Optional) Image inside dropdown for a professional look
              Image.asset(
                product['image'],
                width: 30,
                height: 30,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  product['name'],
                  overflow:
                      TextOverflow.ellipsis, // 👈 prevent long text overflow
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          if (productNumber == 1) {
            selectedProduct1 = value!;
          } else {
            selectedProduct2 = value!;
          }
        });
      },
    );
  }

  Widget _buildPhotoCard(Map<String, dynamic> product) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: PhotoView(
                imageProvider: AssetImage(product['image']),
                backgroundDecoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 2.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[100],
            child: Column(
              children: [
                Text(
                  product['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text("Brand: ${product['brand']}"),
                Text("Rating: ${product['rating']} ⭐"),
                Text("Price: ${product['price']}"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
