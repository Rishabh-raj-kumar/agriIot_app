import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  final String id; // Document ID from Firestore
  final String userId; // ID of the user who submitted the rating
  final String userName; // Optional: Name of the user
  final double rating;
  final String? comment;
  final Timestamp timestamp;

  RatingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    this.comment,
    required this.timestamp,
  });

  factory RatingModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RatingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName:
          data['userName'] ?? 'Anonymous', // Default if name is not stored
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'],
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp,
    };
  }
}
