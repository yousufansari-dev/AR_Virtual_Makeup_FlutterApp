import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Product>> getProducts() {
    return _db
        .collection('products')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Product.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<Category>> getCategories() {
    return _db
        .collection('categories')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Category.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
