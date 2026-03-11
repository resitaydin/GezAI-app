import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Utility class for localizing model display names
class ModelLocalizer {
  /// Get localized transport mode name
  static String getTransportName(BuildContext context, String transportId) {
    final l10n = AppLocalizations.of(context)!;

    switch (transportId) {
      case 'walking':
        return l10n.transportWalkingName;
      case 'public_transit':
        return l10n.transportPublicTransitName;
      case 'driving':
        return l10n.transportDrivingName;
      default:
        return transportId;
    }
  }

  /// Get localized transport mode description
  static String getTransportDescription(BuildContext context, String transportId) {
    final l10n = AppLocalizations.of(context)!;

    switch (transportId) {
      case 'walking':
        return l10n.transportWalkingDescription;
      case 'public_transit':
        return l10n.transportPublicTransitDescription;
      case 'driving':
        return l10n.transportDrivingDescription;
      default:
        return '';
    }
  }

  /// Get localized transport mode "best for" description
  static String getTransportBestFor(BuildContext context, String transportId) {
    final l10n = AppLocalizations.of(context)!;

    switch (transportId) {
      case 'walking':
        return l10n.transportWalkingBestFor;
      case 'public_transit':
        return l10n.transportPublicTransitBestFor;
      case 'driving':
        return l10n.transportDrivingBestFor;
      default:
        return '';
    }
  }

  /// Get localized category name
  static String getCategoryName(BuildContext context, String categoryId) {
    final l10n = AppLocalizations.of(context)!;

    switch (categoryId) {
      case 'mosque':
        return l10n.categoryMosques;
      case 'museum':
        return l10n.categoryMuseums;
      case 'park':
        return l10n.categoryParks;
      case 'restaurant':
        return l10n.categoryRestaurants;
      case 'cafe':
        return l10n.categoryCafes;
      case 'attraction':
        return l10n.categoryAttractions;
      case 'historical':
        return l10n.categoryHistorical;
      case 'shopping':
        return l10n.categoryShopping;
      case 'hotel':
        return l10n.categoryHotels;
      case 'church':
        return l10n.categoryChurches;
      default:
        return categoryId;
    }
  }

  /// Get localized mood name
  static String getMoodName(BuildContext context, String moodId) {
    final l10n = AppLocalizations.of(context)!;

    switch (moodId) {
      case 'romantic':
        return l10n.moodRomantic;
      case 'historical':
        return l10n.moodHistorical;
      case 'relaxing':
        return l10n.moodRelaxing;
      case 'family':
        return l10n.moodFamily;
      case 'scenic':
        return l10n.moodScenic;
      case 'foodie':
        return l10n.moodFoodie;
      case 'photography':
        return l10n.moodPhotography;
      case 'nature':
        return l10n.moodNature;
      case 'adventure':
        return l10n.moodAdventure;
      case 'cultural':
        return l10n.moodCultural;
      case 'spiritual':
        return l10n.moodSpiritual;
      case 'local':
        return l10n.moodLocal;
      case 'hidden_gem':
        return l10n.moodHiddenGem;
      case 'sunset':
        return l10n.moodSunset;
      case 'morning':
        return l10n.moodMorning;
      case 'nightlife':
        return l10n.moodNightlife;
      default:
        return moodId;
    }
  }

  /// Get localized time period name
  static String getTimePeriodName(BuildContext context, String periodId) {
    final l10n = AppLocalizations.of(context)!;

    switch (periodId) {
      case 'morning':
        return l10n.timePeriodMorning;
      case 'afternoon':
        return l10n.timePeriodAfternoon;
      case 'evening':
        return l10n.timePeriodEvening;
      case 'anytime':
        return l10n.timePeriodAnytime;
      default:
        return periodId;
    }
  }

  /// Get localized time period description
  static String getTimePeriodDescription(BuildContext context, String periodId) {
    final l10n = AppLocalizations.of(context)!;

    switch (periodId) {
      case 'morning':
        return l10n.timePeriodMorningDesc;
      case 'afternoon':
        return l10n.timePeriodAfternoonDesc;
      case 'evening':
        return l10n.timePeriodEveningDesc;
      case 'anytime':
        return l10n.timePeriodAnytimeDesc;
      default:
        return '';
    }
  }
}
