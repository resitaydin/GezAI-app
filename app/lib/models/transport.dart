import 'package:flutter/material.dart';

/// Represents a transport mode for route planning
class TransportMode {
  final String id;
  final String name;
  final String description;
  final String bestFor;
  final IconData icon;
  final Color primaryColor;
  final Color backgroundColor;

  const TransportMode({
    required this.id,
    required this.name,
    required this.description,
    required this.bestFor,
    required this.icon,
    required this.primaryColor,
    required this.backgroundColor,
  });

  static const walking = TransportMode(
    id: 'walking',
    name: 'Walking',
    description: 'Explore the historic streets on foot',
    bestFor: 'Best for sightseeing',
    icon: Icons.directions_walk_rounded,
    primaryColor: Color(0xFF10B981), // Emerald
    backgroundColor: Color(0xFFECFDF5),
  );

  static const publicTransit = TransportMode(
    id: 'public_transit',
    name: 'Public Transit',
    description: 'Metro, bus & tram across the city',
    bestFor: 'Best for long distances',
    icon: Icons.directions_transit_rounded,
    primaryColor: Color(0xFF3B82F6), // Blue
    backgroundColor: Color(0xFFEFF6FF),
  );

  static const driving = TransportMode(
    id: 'driving',
    name: 'Driving',
    description: 'Navigate Istanbul by car',
    bestFor: 'Best for flexibility',
    icon: Icons.directions_car_rounded,
    primaryColor: Color(0xFF8B5CF6), // Purple
    backgroundColor: Color(0xFFF5F3FF),
  );

  static const List<TransportMode> allModes = [
    walking,
    publicTransit,
    driving,
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransportMode &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
