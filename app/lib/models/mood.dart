import 'package:flutter/material.dart';

class Mood {
  final String id;
  final String name;
  final String imagePath;
  final IconData icon;

  const Mood({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.icon,
  });

  static const List<Mood> allMoods = [
    Mood(
      id: 'romantic',
      name: 'Romantic',
      imagePath: 'assets/images/moods/romantic.png',
      icon: Icons.favorite_rounded,
    ),
    Mood(
      id: 'historical',
      name: 'Historical',
      imagePath: 'assets/images/moods/historical.png',
      icon: Icons.account_balance_rounded,
    ),
    Mood(
      id: 'relaxing',
      name: 'Relaxing',
      imagePath: 'assets/images/moods/relaxing.png',
      icon: Icons.spa_rounded,
    ),
    Mood(
      id: 'family',
      name: 'Family',
      imagePath: 'assets/images/moods/family.png',
      icon: Icons.family_restroom_rounded,
    ),
    Mood(
      id: 'scenic',
      name: 'Scenic',
      imagePath: 'assets/images/moods/scenic.png',
      icon: Icons.landscape_rounded,
    ),
    Mood(
      id: 'foodie',
      name: 'Foodie',
      imagePath: 'assets/images/moods/foodie.png',
      icon: Icons.restaurant_rounded,
    ),
    Mood(
      id: 'photography',
      name: 'Photography',
      imagePath: 'assets/images/moods/photography.png',
      icon: Icons.camera_alt_rounded,
    ),
    Mood(
      id: 'nature',
      name: 'Nature',
      imagePath: 'assets/images/moods/nature.png',
      icon: Icons.park_rounded,
    ),
    Mood(
      id: 'adventure',
      name: 'Adventure',
      imagePath: 'assets/images/moods/adventure.png',
      icon: Icons.hiking_rounded,
    ),
    Mood(
      id: 'cultural',
      name: 'Cultural',
      imagePath: 'assets/images/moods/cultural.png',
      icon: Icons.theater_comedy_rounded,
    ),
    Mood(
      id: 'spiritual',
      name: 'Spiritual',
      imagePath: 'assets/images/moods/spiritual.png',
      icon: Icons.self_improvement_rounded,
    ),
    Mood(
      id: 'local',
      name: 'Local',
      imagePath: 'assets/images/moods/local.png',
      icon: Icons.storefront_rounded,
    ),
    Mood(
      id: 'hidden_gem',
      name: 'Hidden Gem',
      imagePath: 'assets/images/moods/hiddengem.png',
      icon: Icons.diamond_rounded,
    ),
    Mood(
      id: 'sunset',
      name: 'Sunset',
      imagePath: 'assets/images/moods/sunset.png',
      icon: Icons.wb_twilight_rounded,
    ),
    Mood(
      id: 'morning',
      name: 'Morning',
      imagePath: 'assets/images/moods/morning.png',
      icon: Icons.wb_sunny_rounded,
    ),
    Mood(
      id: 'nightlife',
      name: 'Nightlife',
      imagePath: 'assets/images/moods/nightlife.png',
      icon: Icons.nightlife_rounded,
    ),
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Mood && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
