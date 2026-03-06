import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      width: 150,
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 6),
          Text(product.name, style: TextStyle(fontWeight: FontWeight.bold)),
          Text('\$${product.price}', style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }
}
