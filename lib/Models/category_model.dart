class Category {
  final String id, name, imageUrl;

  Category({required this.id, required this.name, required this.imageUrl});

  factory Category.fromMap(Map<String, dynamic> map, String id) {
    return Category(id: id, name: map['name'], imageUrl: map['imageUrl']);
  }
}
