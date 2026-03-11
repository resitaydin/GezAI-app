import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../models/mood.dart';
import '../models/duration.dart';
import '../models/transport.dart';

/// State class to hold all route generation preferences
class RoutePreferences {
  final List<PlaceCategory> selectedCategories;
  final List<Mood> selectedMoods;
  final DurationPreference? durationPreference;
  final TransportMode? selectedTransport;

  const RoutePreferences({
    this.selectedCategories = const [],
    this.selectedMoods = const [],
    this.durationPreference,
    this.selectedTransport,
  });

  RoutePreferences copyWith({
    List<PlaceCategory>? selectedCategories,
    List<Mood>? selectedMoods,
    DurationPreference? durationPreference,
    TransportMode? selectedTransport,
    bool clearDuration = false,
    bool clearTransport = false,
  }) {
    return RoutePreferences(
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedMoods: selectedMoods ?? this.selectedMoods,
      durationPreference: clearDuration ? null : (durationPreference ?? this.durationPreference),
      selectedTransport: clearTransport ? null : (selectedTransport ?? this.selectedTransport),
    );
  }

  /// Returns a formatted string of selected category names
  String get categoriesSubtitle {
    if (selectedCategories.isEmpty) {
      return 'Museums, Cafes';
    }
    if (selectedCategories.length <= 2) {
      return selectedCategories.map((c) => c.name).join(', ');
    }
    return '${selectedCategories.length} selected';
  }

  /// Returns a formatted string of selected mood names
  String get moodsSubtitle {
    if (selectedMoods.isEmpty) {
      return 'Relaxing, Scenic';
    }
    if (selectedMoods.length <= 2) {
      return selectedMoods.map((m) => m.name).join(', ');
    }
    return '${selectedMoods.length} selected';
  }

  /// Returns a formatted string of selected duration
  String get durationSubtitle {
    if (durationPreference == null) {
      return 'Morning, Anytime';
    }
    return durationPreference!.displayText;
  }

  /// Returns a formatted string of selected transport
  String get transportSubtitle {
    if (selectedTransport == null) {
      return 'Walking';
    }
    return selectedTransport!.name;
  }

  /// Check if any preferences are set
  bool get hasPreferences {
    return selectedCategories.isNotEmpty ||
        selectedMoods.isNotEmpty ||
        durationPreference != null ||
        selectedTransport != null;
  }

  /// Build a Turkish prompt from user preferences
  ///
  /// Converts selected categories, moods, and duration into a natural
  /// language prompt that the LLM can understand.
  String buildPrompt() {
    final parts = <String>[];

    // Categories
    if (selectedCategories.isNotEmpty) {
      final categoryNames = selectedCategories.map((c) => _categoryToTurkish(c.id)).toList();
      if (categoryNames.length == 1) {
        parts.add('${categoryNames.first} görmek istiyorum');
      } else {
        final last = categoryNames.removeLast();
        parts.add('${categoryNames.join(", ")} ve $last görmek istiyorum');
      }
    }

    // Moods
    if (selectedMoods.isNotEmpty) {
      final moodNames = selectedMoods.map((m) => _moodToTurkish(m.id)).toList();
      if (moodNames.length == 1) {
        parts.add('${moodNames.first} bir rota');
      } else {
        final last = moodNames.removeLast();
        parts.add('${moodNames.join(", ")} ve $last bir rota');
      }
    }

    // Duration
    if (durationPreference != null) {
      final hours = durationPreference!.maxHours;
      parts.add('Yaklaşık $hours saat sürecek');

      // Time period
      if (durationPreference!.selectedPeriod != null) {
        final period = _timePeriodToTurkish(durationPreference!.selectedPeriod!.id);
        parts.add('$period için uygun');
      }
    }

    // Default prompt if no preferences
    if (parts.isEmpty) {
      return 'Üsküdar\'da güzel bir gezi rotası oluştur';
    }

    return '${parts.join('. ')}.';
  }

  /// Convert category ID to Turkish
  static String _categoryToTurkish(String categoryId) {
    const categoryMap = {
      'mosque': 'Camileri',
      'museum': 'Müzeleri',
      'park': 'Parkları',
      'restaurant': 'Restoranları',
      'cafe': 'Kafeleri',
      'attraction': 'Turistik yerleri',
      'historical': 'Tarihi mekanları',
      'shopping': 'Alışveriş yerlerini',
      'hotel': 'Otelleri',
      'church': 'Kiliseleri',
    };
    return categoryMap[categoryId] ?? categoryId;
  }

  /// Convert mood ID to Turkish
  static String _moodToTurkish(String moodId) {
    const moodMap = {
      'romantic': 'romantik',
      'historical': 'tarihi',
      'relaxing': 'rahatlatıcı',
      'family': 'aile dostu',
      'scenic': 'manzaralı',
      'foodie': 'yemek odaklı',
      'photography': 'fotoğraf çekimine uygun',
      'nature': 'doğa ile iç içe',
      'adventure': 'macera dolu',
      'cultural': 'kültürel',
      'spiritual': 'manevi',
      'local': 'yerel deneyim sunan',
      'hidden_gem': 'gizli güzellikler içeren',
      'sunset': 'gün batımı için uygun',
      'morning': 'sabah için uygun',
      'nightlife': 'gece hayatı olan',
    };
    return moodMap[moodId] ?? moodId;
  }

  /// Convert time period ID to Turkish
  static String _timePeriodToTurkish(String periodId) {
    const periodMap = {
      'morning': 'sabah',
      'afternoon': 'öğleden sonra',
      'evening': 'akşam',
      'anytime': 'herhangi bir zaman',
    };
    return periodMap[periodId] ?? periodId;
  }
}

/// Notifier to manage route preferences state
class RoutePreferencesNotifier extends StateNotifier<RoutePreferences> {
  RoutePreferencesNotifier() : super(const RoutePreferences());

  void setCategories(List<PlaceCategory> categories) {
    state = state.copyWith(selectedCategories: categories);
  }

  void setMoods(List<Mood> moods) {
    state = state.copyWith(selectedMoods: moods);
  }

  void setDuration(DurationPreference? duration) {
    state = state.copyWith(durationPreference: duration);
  }

  void clearDuration() {
    state = state.copyWith(clearDuration: true);
  }

  void setTransport(TransportMode? transport) {
    state = state.copyWith(selectedTransport: transport);
  }

  void clearTransport() {
    state = state.copyWith(clearTransport: true);
  }

  void clearAll() {
    state = const RoutePreferences();
  }
}

/// Provider for route preferences
final routePreferencesProvider =
    StateNotifierProvider<RoutePreferencesNotifier, RoutePreferences>(
  (ref) => RoutePreferencesNotifier(),
);
