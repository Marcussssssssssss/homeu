import 'package:flutter/material.dart';

class PropertyItem {
  const PropertyItem({
    required this.name,
    required this.location,
    required this.pricePerMonth,
    required this.rating,
    required this.accentColor,
    required this.description,
    required this.ownerName,
    required this.ownerRole,
    required this.photoColors,
  });

  final String name;
  final String location;
  final String pricePerMonth;
  final double rating;
  final Color accentColor;
  final String description;
  final String ownerName;
  final String ownerRole;
  final List<Color> photoColors;
}

