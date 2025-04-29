// lib/models/service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class Service {
  final String?
      id; // Make ID nullable for creating new objects before Firestore assigns one
  final String title;
  final String description;
  final double price;
  final String priceUnit;
  final String imageUrl;
  final double rating;
  final String sellerName;
  final String contactNumber;
  final LatLng location; // Keep using LatLng in the app model

  Service({
    this.id, // Nullable
    required this.title,
    required this.description,
    required this.price,
    required this.priceUnit,
    required this.imageUrl,
    required this.rating,
    required this.sellerName,
    required this.contactNumber,
    required this.location,
  });

  // Factory constructor to create a Service instance from a Firestore document
  factory Service.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    GeoPoint geoPoint =
        data['location'] ?? GeoPoint(0, 0); // Handle null location

    return Service(
      id: doc.id, // Get the document ID
      title: data['title'] ?? 'No Title',
      description: data['description'] ?? 'No Description',
      price: (data['price'] ?? 0.0).toDouble(),
      priceUnit: data['priceUnit'] ?? 'unit',
      imageUrl: data['imageUrl'] ?? '', // Handle missing image URL
      rating: (data['rating'] ?? 0.0).toDouble(),
      sellerName: data['sellerName'] ?? 'Unknown Seller',
      contactNumber: data['contactNumber'] ?? '',
      location: LatLng(geoPoint.latitude, geoPoint.longitude),
    );
  }

  // Method to convert a Service instance to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'priceUnit': priceUnit,
      'imageUrl': imageUrl,
      'rating': rating,
      'sellerName': sellerName,
      'contactNumber': contactNumber,
      'location': GeoPoint(
          location.latitude, location.longitude), // Convert to GeoPoint
      'timestamp': FieldValue.serverTimestamp(), // Optional: add a timestamp
    };
  }
}
