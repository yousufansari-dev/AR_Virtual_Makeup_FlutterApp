import 'package:flutter/material.dart';
import '../models/category_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: CachedNetworkImage(
              imageUrl: category.imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 6),
          Text(category.name),
        ],
      ),
    );
  }
}
