import 'package:flutter/material.dart';

class GarageEntity {

  const GarageEntity({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.listingsCount,
    required this.isVerified,
    required this.imageColor,
  });
  final String id;
  final String name;
  final String location;
  final double rating;
  final int reviewCount;
  final int listingsCount;
  final bool isVerified;
  final Color imageColor;
}
