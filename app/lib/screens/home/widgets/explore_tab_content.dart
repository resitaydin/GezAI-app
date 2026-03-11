import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../providers/route_preferences_provider.dart';
import 'filter_tags_widget.dart';
import 'category_card_widget.dart';
import 'create_route_button.dart';
import 'category_selection_sheet.dart';
import 'mood_selection_sheet.dart';
import 'duration_selection_sheet.dart';
import 'transport_selection_sheet.dart';
import '../../../models/duration.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/model_localizer.dart';

class ExploreTabContent extends ConsumerStatefulWidget {
  final VoidCallback? onDurationTap;
  final VoidCallback? onTransportTap;
  final VoidCallback? onCreateRoute;
  final VoidCallback? onAIButtonTap;

  const ExploreTabContent({
    super.key,
    this.onDurationTap,
    this.onTransportTap,
    this.onCreateRoute,
    this.onAIButtonTap,
  });

  @override
  ConsumerState<ExploreTabContent> createState() => _ExploreTabContentState();
}

class _ExploreTabContentState extends ConsumerState<ExploreTabContent> {
  final Completer<GoogleMapController> _mapController = Completer();

  String _selectedTagId = 'uskudar';

  // Default location tags (Istanbul districts)
  final List<FilterTag> _locationTags = const [
    FilterTag(id: 'uskudar', label: 'Üsküdar'),
  ];

  // Istanbul center coordinates
  static const LatLng _istanbulCenter = LatLng(41.0082, 28.9784);

  void _onTagSelected(String tagId) {
    setState(() {
      _selectedTagId = tagId;
    });
    _animateToLocation(tagId);
  }

  Future<void> _animateToLocation(String tagId) async {
    final controller = await _mapController.future;
    LatLng target;

    switch (tagId) {
      case 'sultanahmet':
        target = const LatLng(41.0054, 28.9768);
        break;
      case 'kadikoy':
        target = const LatLng(40.9903, 29.0293);
        break;
      case 'beyoglu':
        target = const LatLng(41.0370, 28.9770);
        break;
      case 'uskudar':
        target = const LatLng(41.0256, 29.0151);
        break;
      case 'besiktas':
        target = const LatLng(41.0429, 29.0069);
        break;
      default:
        target = _istanbulCenter;
    }

    controller.animateCamera(
      CameraUpdate.newLatLngZoom(target, 12),
    );
  }

  Future<void> _openCategorySelection() async {
    final preferences = ref.read(routePreferencesProvider);
    final result = await CategorySelectionSheet.show(
      context,
      initialSelection: preferences.selectedCategories,
    );

    if (result != null) {
      ref.read(routePreferencesProvider.notifier).setCategories(result);
    }
  }

  Future<void> _openMoodSelection() async {
    final preferences = ref.read(routePreferencesProvider);
    final result = await MoodSelectionSheet.show(
      context,
      initialSelection: preferences.selectedMoods,
    );

    if (result != null) {
      ref.read(routePreferencesProvider.notifier).setMoods(result);
    }
  }

  Future<void> _openDurationSelection() async {
    final preferences = ref.read(routePreferencesProvider);
    final result = await DurationSelectionSheet.show(
      context,
      initialPreference: preferences.durationPreference ?? const DurationPreference(),
    );

    if (result != null) {
      ref.read(routePreferencesProvider.notifier).setDuration(result);
    }
  }

  Future<void> _openTransportSelection() async {
    final preferences = ref.read(routePreferencesProvider);
    final result = await TransportSelectionSheet.show(
      context,
      initialSelection: preferences.selectedTransport,
    );

    if (result != null) {
      ref.read(routePreferencesProvider.notifier).setTransport(result);
    }
  }

  void _handleCategoryTap(String categoryId) {
    switch (categoryId) {
      case 'categories':
        _openCategorySelection();
        break;
      case 'mood':
        _openMoodSelection();
        break;
      case 'duration':
        _openDurationSelection();
        break;
      case 'transport':
        _openTransportSelection();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final preferences = ref.watch(routePreferencesProvider);

    // Build category options with dynamic subtitles from preferences
    final l10n = AppLocalizations.of(context)!;
    final categoryOptions = [
      CategoryOption(
        id: 'categories',
        title: l10n.exploreCategories,
        subtitle: _getCategoriesSubtitle(preferences, l10n),
        icon: Icons.account_balance_rounded,
        iconColor: const Color(0xFF3B82F6),
        iconBgGradient: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
      ),
      CategoryOption(
        id: 'mood',
        title: l10n.exploreMood,
        subtitle: _getMoodsSubtitle(preferences, l10n),
        icon: Icons.emoji_emotions_rounded,
        iconColor: const Color(0xFFF97316),
        iconBgGradient: const [Color(0xFFF97316), Color(0xFFEA580C)],
      ),
      CategoryOption(
        id: 'duration',
        title: l10n.exploreDuration,
        subtitle: _getDurationSubtitle(preferences, l10n),
        icon: Icons.schedule_rounded,
        iconColor: const Color(0xFF10B981),
        iconBgGradient: const [Color(0xFF10B981), Color(0xFF059669)],
      ),
      CategoryOption(
        id: 'transport',
        title: l10n.exploreTransport,
        subtitle: _getTransportSubtitle(preferences, l10n),
        icon: Icons.tram_rounded,
        iconColor: const Color(0xFF6366F1),
        iconBgGradient: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
      ),
    ];

    return Container(
      color: const Color(0xFFF6F7F8),
      child: Column(
        children: [
          // Map Section - takes remaining space, extends 24px behind bottom panel corners
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Map - positioned to extend below into the bottom panel area
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: -24, // Extend 24px to cover rounded corners
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: _istanbulCenter,
                      zoom: 12,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _mapController.complete(controller);
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: false,
                    mapType: MapType.normal,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top - 100,
                      bottom: 40, // Extra padding to compensate for the extension
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Fixed Bottom Panel
          _buildBottomPanel(bottomPadding, categoryOptions),
        ],
      ),
    );
  }

  String _getCategoriesSubtitle(RoutePreferences prefs, AppLocalizations l10n) {
    if (prefs.selectedCategories.isEmpty) {
      return l10n.defaultCategoriesHint;
    }
    if (prefs.selectedCategories.length <= 2) {
      return prefs.selectedCategories
          .map((c) => ModelLocalizer.getCategoryName(context, c.id))
          .join(', ');
    }
    return l10n.selectedCount(prefs.selectedCategories.length);
  }

  String _getMoodsSubtitle(RoutePreferences prefs, AppLocalizations l10n) {
    if (prefs.selectedMoods.isEmpty) {
      return l10n.defaultMoodsHint;
    }
    if (prefs.selectedMoods.length <= 2) {
      return prefs.selectedMoods
          .map((m) => ModelLocalizer.getMoodName(context, m.id))
          .join(', ');
    }
    return l10n.selectedCount(prefs.selectedMoods.length);
  }

  String _getDurationSubtitle(RoutePreferences prefs, AppLocalizations l10n) {
    if (prefs.durationPreference == null) {
      return l10n.defaultDurationHint;
    }
    final dp = prefs.durationPreference!;
    final hours = dp.maxHours;
    final hourLabel = hours == 1 ? l10n.hourSingular : l10n.hourPlural;
    if (dp.selectedPeriod == null) {
      return '$hours $hourLabel';
    }
    final periodName = ModelLocalizer.getTimePeriodName(context, dp.selectedPeriod!.id);
    return '$periodName, $hours $hourLabel';
  }

  String _getTransportSubtitle(RoutePreferences prefs, AppLocalizations l10n) {
    if (prefs.selectedTransport == null) {
      return l10n.defaultTransportHint;
    }
    return ModelLocalizer.getTransportName(context, prefs.selectedTransport!.id);
  }

  Widget _buildBottomPanel(
      double bottomPadding, List<CategoryOption> categoryOptions) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          _buildSheetHandle(),

          // Search Bar
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          //   child: SearchBarWidget(
          //     readOnly: true,
          //     onTap: () {
          //       // Navigate to search screen
          //     },
          //   ),
          // ),

          // Location Filter Tags
          FilterTagsWidget(
            tags: _locationTags,
            activeTagId: _selectedTagId,
            onTagSelected: _onTagSelected,
          ),

          const SizedBox(height: 16),

          // Category Cards Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: CategoryCardWidget(
                    option: categoryOptions[0],
                    onTap: () => _handleCategoryTap(categoryOptions[0].id),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CategoryCardWidget(
                    option: categoryOptions[1],
                    onTap: () => _handleCategoryTap(categoryOptions[1].id),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: CategoryCardWidget(
                    option: categoryOptions[2],
                    onTap: () => _handleCategoryTap(categoryOptions[2].id),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CategoryCardWidget(
                    option: categoryOptions[3],
                    onTap: () => _handleCategoryTap(categoryOptions[3].id),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Create Route Button
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding + 16),
            child: CreateRouteButton(
              onTap: widget.onCreateRoute,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheetHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
