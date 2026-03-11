import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/place.dart';
import '../models/route_result.dart';
import '../providers/place_provider.dart';
import '../providers/place_about_provider.dart';
import '../l10n/app_localizations.dart';

/// Data class for place preview information
/// Can be created from either a Place or RouteStop
class PlacePreviewData {
  final String placeId;
  final String name;
  final String? description;
  final String? about;
  final String? location; // e.g. "Üsküdar, Istanbul"
  final String? category;
  final double? rating;
  final int? totalRatings;
  final List<String> photoUrls;
  final bool isAboutLoading;

  PlacePreviewData({
    required this.placeId,
    required this.name,
    this.description,
    this.about,
    this.location,
    this.category,
    this.rating,
    this.totalRatings,
    this.photoUrls = const [],
    this.isAboutLoading = false,
  });

  factory PlacePreviewData.fromPlace(Place place) {
    return PlacePreviewData(
      placeId: place.placeId,
      name: place.name,
      description: place.description ?? place.descriptionEn,
      about: place.about,
      location: '${place.region}, ${place.city}',
      category: place.category,
      rating: place.rating,
      totalRatings: place.totalRatings,
      photoUrls: place.photos.map((p) => p.url).whereType<String>().toList(),
      isAboutLoading: false,
    );
  }

  factory PlacePreviewData.fromRouteStop(RouteStop stop, {String? region}) {
    return PlacePreviewData(
      placeId: stop.placeId,
      name: stop.name,
      description: stop.description,
      about: null, // Will be loaded from API
      location: region,
      category: stop.category,
      rating: stop.rating,
      totalRatings: null,
      photoUrls: stop.photoUrl != null ? [stop.photoUrl!] : [],
      isAboutLoading: true, // Mark as loading until API returns
    );
  }

  String get formattedRating {
    if (rating == null) return '';
    return rating!.toStringAsFixed(1);
  }

  String get formattedTotalRatings {
    if (totalRatings == null) return '';
    if (totalRatings! >= 1000) {
      return '(${(totalRatings! / 1000).toStringAsFixed(1)}k)';
    }
    return '($totalRatings)';
  }

  String get categoryLabel {
    if (category == null) return '';
    // Capitalize first letter of each word
    return category!
        .split('_')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : word)
        .join(' ');
  }
}

/// A bottom sheet that displays place preview information
class PlacePreviewSheet extends StatefulWidget {
  final PlacePreviewData data;
  final VoidCallback? onFavoritePressed;
  final VoidCallback? onMorePressed;
  final VoidCallback? onClose;

  const PlacePreviewSheet({
    super.key,
    required this.data,
    this.onFavoritePressed,
    this.onMorePressed,
    this.onClose,
  });

  /// Shows the place preview sheet as a modal bottom sheet
  static Future<void> show(
    BuildContext context, {
    required PlacePreviewData data,
    VoidCallback? onFavoritePressed,
    VoidCallback? onMorePressed,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlacePreviewSheet(
        data: data,
        onFavoritePressed: onFavoritePressed,
        onMorePressed: onMorePressed,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Shows the place preview sheet with data fetched from the API
  /// Displays initialData immediately while fetching full details
  /// Uses POST endpoint to create/get place by name and region
  static Future<void> showWithFetch(
    BuildContext context, {
    required String name,
    required String region,
    PlacePreviewData? initialData,
    VoidCallback? onFavoritePressed,
    VoidCallback? onMorePressed,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PlacePreviewSheetLoader(
        name: name,
        region: region,
        initialData: initialData,
        onFavoritePressed: onFavoritePressed,
        onMorePressed: onMorePressed,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  State<PlacePreviewSheet> createState() => _PlacePreviewSheetState();
}

class _PlacePreviewSheetState extends State<PlacePreviewSheet> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  // Design colors from the HTML
  static const Color primaryTurquoise = Color(0xFF2DD4BF);
  static const Color deepBlue = Color(0xFF1E3A5F);
  static const Color slateGray = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        children: [
          // Drag handle
          _buildDragHandle(),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero image section
                  _buildHeroImage(),
                  // Place info section
                  _buildPlaceInfo(),
                  // About section
                  _buildAboutSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Center(
        child: Container(
          width: 48,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    final hasPhotos = widget.data.photoUrls.isNotEmpty;

    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFFE2E8F0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image or placeholder
          if (hasPhotos)
            PageView.builder(
              controller: _pageController,
              itemCount: widget.data.photoUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: widget.data.photoUrls[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: const Color(0xFFE2E8F0),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: primaryTurquoise,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => _buildPlaceholder(),
                );
              },
            )
          else
            _buildPlaceholder(),

          // Gradient overlay (ignore pointer to allow swipes through)
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          // Image pagination dots
          if (hasPhotos && widget.data.photoUrls.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.data.photoUrls.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: index == _currentImageIndex ? 24 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: index == _currentImageIndex
                          ? primaryTurquoise
                          : Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFE2E8F0),
      child: Center(
        child: Icon(
          _getCategoryIcon(widget.data.category),
          size: 64,
          color: slateGray,
        ),
      ),
    );
  }

  Widget _buildPlaceInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and Open Now badge row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.data.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: deepBlue,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Open Now badge (placeholder - can be made dynamic)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primaryTurquoise.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppLocalizations.of(context)!.openNow,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: primaryTurquoise,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Location
          if (widget.data.location != null)
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 18,
                  color: slate500,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.data.location!,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: slate500,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 12),

          // Rating row
          _buildRatingRow(),

          const SizedBox(height: 20),

          // Divider
          Container(
            height: 1,
            color: const Color(0xFFF1F5F9),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingRow() {
    final hasRating = widget.data.rating != null;

    return Row(
      children: [
        if (hasRating) ...[
          // Rating badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: primaryTurquoise,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              widget.data.formattedRating,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Stars
          _buildStars(widget.data.rating!),
          const SizedBox(width: 4),
          // Total ratings
          if (widget.data.totalRatings != null)
            Text(
              widget.data.formattedTotalRatings,
              style: TextStyle(
                fontSize: 14,
                color: slateGray,
              ),
            ),
          const SizedBox(width: 8),
          // Dot separator
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
        ],
        // Category
        if (widget.data.category != null)
          Text(
            widget.data.categoryLabel,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: slate500,
            ),
          ),
      ],
    );
  }

  Widget _buildStars(double rating) {
    final fullStars = rating.floor();
    final hasHalfStar = rating - fullStars >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        IconData icon;
        if (index < fullStars) {
          icon = Icons.star;
        } else if (index == fullStars && hasHalfStar) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }
        return Icon(
          icon,
          size: 16,
          color: primaryTurquoise,
        );
      }),
    );
  }

  Widget _buildAboutSection() {
    // Use about field, fall back to description
    final aboutText = widget.data.about ?? widget.data.description;
    final isLoading = widget.data.isAboutLoading && aboutText == null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.aboutSection,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: deepBlue,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),
          if (isLoading)
            _buildAboutShimmer()
          else if (aboutText != null && aboutText.isNotEmpty)
            Text(
              aboutText,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: slate500,
                height: 1.6,
              ),
            )
          else
            Text(
              AppLocalizations.of(context)!.noDescriptionAvailable,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: slateGray,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAboutShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShimmerLine(width: double.infinity),
        const SizedBox(height: 8),
        _buildShimmerLine(width: double.infinity),
        const SizedBox(height: 8),
        _buildShimmerLine(width: 200),
      ],
    );
  }

  Widget _buildShimmerLine({required double width}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 0.7),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Container(
          width: width,
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: [
                const Color(0xFFE2E8F0).withValues(alpha: value),
                const Color(0xFFF1F5F9),
                const Color(0xFFE2E8F0).withValues(alpha: value),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
      onEnd: () {
        // This creates the shimmer animation loop
        if (mounted) setState(() {});
      },
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'mosque':
        return Icons.mosque;
      case 'museum':
        return Icons.museum;
      case 'park':
        return Icons.park;
      case 'restaurant':
        return Icons.restaurant;
      case 'cafe':
        return Icons.local_cafe;
      case 'attraction':
        return Icons.attractions;
      case 'historical':
        return Icons.account_balance;
      default:
        return Icons.place;
    }
  }
}

/// Internal loader widget that fetches place details from API
/// Shows initialData immediately while loading, replaces with full data when ready
/// Only generates "about" text using Firebase AI if not already in Firestore
class _PlacePreviewSheetLoader extends ConsumerWidget {
  final String name;
  final String region;
  final PlacePreviewData? initialData;
  final VoidCallback? onFavoritePressed;
  final VoidCallback? onMorePressed;
  final VoidCallback? onClose;

  const _PlacePreviewSheetLoader({
    required this.name,
    required this.region,
    this.initialData,
    this.onFavoritePressed,
    this.onMorePressed,
    this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = PlaceDetailParams(name: name, region: region);
    final placeAsync = ref.watch(placeDetailProvider(params));

    return placeAsync.when(
      data: (place) {
        // Check if place already has about text from Firestore
        final hasAbout = place.about != null && place.about!.isNotEmpty;

        if (hasAbout) {
          // Place already has about text - use it directly (no AI needed)
          final data = PlacePreviewData.fromPlace(place);
          return PlacePreviewSheet(
            data: data,
            onFavoritePressed: onFavoritePressed,
            onMorePressed: onMorePressed,
            onClose: onClose,
          );
        }

        // No about text in Firestore - need to generate via AI
        // Only NOW do we watch the about provider
        return _PlaceAboutGenerator(
          place: place,
          name: name,
          region: region,
          onFavoritePressed: onFavoritePressed,
          onMorePressed: onMorePressed,
          onClose: onClose,
        );
      },
      loading: () {
        // Show initial data while loading, or a loading state if no initial data
        if (initialData != null) {
          return PlacePreviewSheet(
            data: initialData!,
            onFavoritePressed: onFavoritePressed,
            onMorePressed: onMorePressed,
            onClose: onClose,
          );
        }
        // Show loading placeholder when no initial data
        return _buildLoadingSheet(context);
      },
      error: (error, stack) {
        // On error, fall back to initial data (graceful degradation)
        if (initialData != null) {
          return PlacePreviewSheet(
            data: initialData!,
            onFavoritePressed: onFavoritePressed,
            onMorePressed: onMorePressed,
            onClose: onClose,
          );
        }
        // Show error state when no fallback data
        return _buildErrorSheet(context);
      },
    );
  }

  Widget _buildLoadingSheet(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Center(
              child: Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2DD4BF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorSheet(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Center(
              child: Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.unableToLoadPlaceDetails,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Separate widget that generates "about" text via AI
/// Only instantiated when place doesn't have about text in Firestore
class _PlaceAboutGenerator extends ConsumerWidget {
  final Place place;
  final String name;
  final String region;
  final VoidCallback? onFavoritePressed;
  final VoidCallback? onMorePressed;
  final VoidCallback? onClose;

  const _PlaceAboutGenerator({
    required this.place,
    required this.name,
    required this.region,
    this.onFavoritePressed,
    this.onMorePressed,
    this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only now do we trigger AI generation
    final aboutParams = PlaceAboutParams(name: name, region: region);
    final aboutAsync = ref.watch(placeAboutProvider(aboutParams));

    return aboutAsync.when(
      data: (aboutText) {
        final data = PlacePreviewData(
          placeId: place.placeId,
          name: place.name,
          description: place.description ?? place.descriptionEn,
          about: aboutText,
          location: '${place.region}, ${place.city}',
          category: place.category,
          rating: place.rating,
          totalRatings: place.totalRatings,
          photoUrls: place.photos.map((p) => p.url).whereType<String>().toList(),
          isAboutLoading: false,
        );
        return PlacePreviewSheet(
          data: data,
          onFavoritePressed: onFavoritePressed,
          onMorePressed: onMorePressed,
          onClose: onClose,
        );
      },
      loading: () {
        // Show place data with about loading shimmer
        final data = PlacePreviewData(
          placeId: place.placeId,
          name: place.name,
          description: place.description ?? place.descriptionEn,
          about: null,
          location: '${place.region}, ${place.city}',
          category: place.category,
          rating: place.rating,
          totalRatings: place.totalRatings,
          photoUrls: place.photos.map((p) => p.url).whereType<String>().toList(),
          isAboutLoading: true,
        );
        return PlacePreviewSheet(
          data: data,
          onFavoritePressed: onFavoritePressed,
          onMorePressed: onMorePressed,
          onClose: onClose,
        );
      },
      error: (error, stack) {
        // Failed to generate about - show place without it
        final data = PlacePreviewData.fromPlace(place);
        return PlacePreviewSheet(
          data: data,
          onFavoritePressed: onFavoritePressed,
          onMorePressed: onMorePressed,
          onClose: onClose,
        );
      },
    );
  }
}
