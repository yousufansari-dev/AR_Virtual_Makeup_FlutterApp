import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String userName;
  final String comment;
  final double rating;
  final DateTime timestamp;

  Review({
    required this.userName,
    required this.comment,
    required this.rating,
    required this.timestamp,
  });

  factory Review.fromFirestore(QueryDocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Review(
      userName: data['userName'] ?? 'Anonymous',
      comment: data['comment'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
