// lib/models/service.dart

import 'package:flutter/material.dart'; // Import for Comment model (if put here)

// --- Model for Service ---
class Service {
  final String id;
  final String name;
  final String description;
  final double pricePerHour; // Example price
  final double rating; // 0.0 to 5.0
  final String category;
  final String location; // Example location string
  final String imageUrl; // Optional image URL
  List<Comment> comments; // Add comments list

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerHour,
    required this.rating,
    required this.category,
    required this.location,
    this.imageUrl =
        'https://via.placeholder.com/150', // Default placeholder image
    List<Comment>? comments, // Initialize comments
  }) : this.comments = comments ?? []; // Use null-aware operator

  // Factory method to create a Service from a map (useful if loading from JSON/DB)
  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      pricePerHour: map['pricePerHour'].toDouble(),
      rating: map['rating'].toDouble(),
      category: map['category'],
      location: map['location'],
      imageUrl: map['imageUrl'] ?? 'https://via.placeholder.com/150',
      // Comments would need deserialization if stored in map
      comments: (map['comments'] as List?)
              ?.map((commentMap) => Comment.fromMap(commentMap))
              .toList() ??
          [],
    );
  }

  // Method to convert Service to a map (useful for saving to JSON/DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pricePerHour': pricePerHour,
      'rating': rating,
      'category': category,
      'location': location,
      'imageUrl': imageUrl,
      // Comments would need serialization
      'comments': comments.map((comment) => comment.toMap()).toList(),
    };
  }
}

// --- Model for Comment ---
class Comment {
  final String userId; // ID of the user who commented
  final String userName; // Name of the user
  final String text; // Comment text
  final DateTime timestamp; // When the comment was made

  Comment({
    required this.userId,
    required this.userName,
    required this.text,
    required this.timestamp,
  });

  // Factory method to create a Comment from a map
  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      userId: map['userId'],
      userName: map['userName'],
      text: map['text'],
      timestamp: DateTime.parse(
          map['timestamp']), // Assuming timestamp is stored as ISO 8601 string
    );
  }

  // Method to convert Comment to a map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'text': text,
      'timestamp': timestamp.toIso8601String(), // Store as ISO 8601 string
    };
  }
}
