import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const List<String> listingCategories = [
  'Hospital',
  'Police Station',
  'Library',
  'Restaurant',
  'Café',
  'Park',
  'Tourist Attraction',
];

IconData getCategoryIcon(String category) {
  switch (category) {
    case 'Hospital':
      return Icons.local_hospital_rounded;
    case 'Police Station':
      return Icons.local_police_rounded;
    case 'Library':
      return Icons.local_library_rounded;
    case 'Restaurant':
      return Icons.restaurant_rounded;
    case 'Café':
      return Icons.coffee_rounded;
    case 'Park':
      return Icons.park_rounded;
    case 'Tourist Attraction':
      return Icons.attractions_rounded;
    default:
      return Icons.place_rounded;
  }
}

class Listing {
  final String? id;
  final String name;
  final String category;
  final String address;
  final String contactNumber;
  final String description;
  final double latitude;
  final double longitude;
  final String createdBy;
  final DateTime? createdAt;

  const Listing({
    this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.contactNumber,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.createdBy,
    this.createdAt,
  });

  factory Listing.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Listing(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      address: data['address'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      description: data['description'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'address': address,
      'contactNumber': contactNumber,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'createdBy': createdBy,
    };
  }
}
