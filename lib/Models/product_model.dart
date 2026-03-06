class Product {
  final String id, name, imageUrl, category;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.price,
  });

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'],
      imageUrl: map['imageUrl'],
      category: map['category'],
      price: map['price'].toDouble(),
    );
  }
}
