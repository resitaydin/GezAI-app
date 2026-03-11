import 'package:flutter/material.dart';

/// Represents a time period for route planning
class TimePeriod {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String iconAsset; // For custom icons/emojis
  final Color primaryColor;
  final Color backgroundColor;
  final int defaultMinHours;
  final int defaultMaxHours;

  const TimePeriod({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.iconAsset = '',
    required this.primaryColor,
    required this.backgroundColor,
    required this.defaultMinHours,
    required this.defaultMaxHours,
  });

  static const morning = TimePeriod(
    id: 'morning',
    name: 'Morning',
    description: '6 AM - 12 PM',
    icon: Icons.wb_sunny_rounded,
    primaryColor: Color(0xFFFBBF24), // Amber/Yellow
    backgroundColor: Color(0xFFFEF3C7),
    defaultMinHours: 1,
    defaultMaxHours: 3,
  );

  static const afternoon = TimePeriod(
    id: 'afternoon',
    name: 'Afternoon',
    description: '12 PM - 6 PM',
    icon: Icons.wb_twilight_rounded,
    primaryColor: Color(0xFFF97316), // Orange
    backgroundColor: Color(0xFFFFF7ED),
    defaultMinHours: 2,
    defaultMaxHours: 4,
  );

  static const evening = TimePeriod(
    id: 'evening',
    name: 'Evening',
    description: '6 PM - 12 AM',
    icon: Icons.nights_stay_rounded,
    primaryColor: Color(0xFF6366F1), // Indigo
    backgroundColor: Color(0xFFEEF2FF),
    defaultMinHours: 2,
    defaultMaxHours: 4,
  );

  static const anytime = TimePeriod(
    id: 'anytime',
    name: 'Anytime',
    description: 'Flexible timing',
    icon: Icons.schedule_rounded,
    primaryColor: Color(0xFF10B981), // Emerald/Green
    backgroundColor: Color(0xFFECFDF5),
    defaultMinHours: 1,
    defaultMaxHours: 8,
  );

  static const List<TimePeriod> allPeriods = [
    morning,
    afternoon,
    evening,
    anytime,
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimePeriod &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Represents the duration preference for a route
class DurationPreference {
  final TimePeriod? selectedPeriod;
  final int minHours;
  final int maxHours;

  const DurationPreference({
    this.selectedPeriod,
    this.minHours = 1,
    this.maxHours = 4,
  });

  DurationPreference copyWith({
    TimePeriod? selectedPeriod,
    int? minHours,
    int? maxHours,
    bool clearPeriod = false,
  }) {
    return DurationPreference(
      selectedPeriod: clearPeriod ? null : (selectedPeriod ?? this.selectedPeriod),
      minHours: minHours ?? this.minHours,
      maxHours: maxHours ?? this.maxHours,
    );
  }

  String get displayText {
    if (selectedPeriod == null) {
      return '$minHours-$maxHours hours';
    }
    return '${selectedPeriod!.name}, $minHours-$maxHours hrs';
  }

  String get shortDisplayText {
    if (minHours == maxHours) {
      return '$minHours hour${minHours > 1 ? 's' : ''}';
    }
    return '$minHours-$maxHours hours';
  }
}
