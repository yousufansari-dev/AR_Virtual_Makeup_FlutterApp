import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> hasUserPurchasedProduct(String userId, String productId) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .get();

    for (var doc in snapshot.docs) {
      List items = doc.data()['items'] ?? [];
      for (var p in items) {
        if (p['productId'] == productId) {
          return true;
        }
      }
    }
    return false;
  }

  Future<bool> hasUserReviewedProduct(String userId, String productId) async {
    final snapshot = await _firestore
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .where('productId', isEqualTo: productId)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> submitReview({
    required String productId,
    required String userId,
    required String userName,
    required String comment,
    required double rating,
  }) async {
    await _firestore.collection('reviews').add({
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'comment': comment,
      'rating': rating,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Review>> getReviews(String productId) async {
    final snapshot = await _firestore
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();
  }

  Future<double> getAverageRating(String productId) async {
    final snapshot = await _firestore
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .get();

    if (snapshot.docs.isEmpty) return 0.0;

    double total = 0;
    for (var doc in snapshot.docs) {
      total += (doc['rating'] ?? 0).toDouble();
    }

    return total / snapshot.docs.length;
  }
}
