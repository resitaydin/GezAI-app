import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../models/advice_route.dart';
import '../../../utils/responsive_utils.dart';
import '../../../l10n/app_localizations.dart';

class AdviceRouteCard extends StatefulWidget {
  final AdviceRouteListItem route;
  final ResponsiveUtils responsive;
  final VoidCallback? onTap;
  final bool isLoading;

  const AdviceRouteCard({
    super.key,
    required this.route,
    required this.responsive,
    this.onTap,
    this.isLoading = false,
  });

  @override
  State<AdviceRouteCard> createState() => _AdviceRouteCardState();
}

class _AdviceRouteCardState extends State<AdviceRouteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(AdviceRouteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isLoading ? _pulseAnimation.value : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(widget.responsive.cardRadius + 8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E3A5F).withValues(alpha: 0.06),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: const Color(0xFF1E3A5F).withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
              border: Border.all(
                color: widget.isLoading
                    ? const Color(0xFF667EEA).withValues(alpha: 0.3)
                    : const Color(0xFFE2E8F0).withValues(alpha: 0.8),
                width: widget.isLoading ? 2 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(widget.responsive.cardRadius + 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSection(),
                  _buildContentSection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection() {
    final imageHeight = widget.responsive.valueByScreenSize(
      compact: 160.0,
      regular: 175.0,
      tall: 220.0,
    );

    return Stack(
      children: [
        // Main Image with gradient overlay
        ClipRRect(
          child: widget.route.thumbnailUrl != null
              ? Stack(
                  children: [
                    Image.network(
                      widget.route.thumbnailUrl!,
                      height: imageHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildGradientPlaceholder(imageHeight);
                      },
                    ),
                    // Gradient overlay for better text readability
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.1),
                              Colors.black.withValues(alpha: 0.5),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : _buildGradientPlaceholder(imageHeight),
        ),
        // Category Badge (top right)
        if (widget.route.category.isNotEmpty)
          Positioned(
            top: widget.responsive.contentPadding - 4,
            right: widget.responsive.contentPadding - 4,
            child: _buildCategoryBadge(),
          ),
        // Tags at bottom
        if (widget.route.displayTags.isNotEmpty)
          Positioned(
            bottom: widget.responsive.contentPadding - 4,
            left: widget.responsive.contentPadding - 4,
            right: widget.responsive.contentPadding - 4,
            child: _buildTagsRow(),
          ),
      ],
    );
  }

  Widget _buildGradientPlaceholder(double height) {
    final iconContainerSize = widget.responsive.valueByScreenSize(
      compact: 56.0,
      regular: 64.0,
      tall: 72.0,
    );

    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
            Color(0xFFF093FB),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Animated decorative circles
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 60,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
          ),
          // Center Icon
          Center(
            child: Container(
              width: iconContainerSize,
              height: iconContainerSize,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius:
                    BorderRadius.circular(widget.responsive.borderRadius + 8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.explore_rounded,
                color: Colors.white,
                size: iconContainerSize * 0.5,
              ),
            ),
          ),
          // Bottom gradient
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge() {
    final firstCategory = widget.route.category.first;
    return Builder(
      builder: (context) {
        final categoryLabel = _getCategoryLabel(firstCategory, context);
        final categoryIcon = _getCategoryIcon(firstCategory);

        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.responsive.borderRadius + 2),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: widget.responsive.spacingSmall + 2,
                vertical: widget.responsive.spacingXS + 2,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius:
                    BorderRadius.circular(widget.responsive.borderRadius + 2),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                categoryIcon,
                color: Colors.white,
                size: widget.responsive.captionFontSize + 1,
              ),
              SizedBox(width: widget.responsive.spacingXS),
              Text(
                categoryLabel,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.responsive.captionFontSize - 1,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildTagsRow() {
    return Row(
      children: widget.route.displayTags.map((tag) {
        return Padding(
          padding: EdgeInsets.only(right: widget.responsive.spacingSmall - 2),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(widget.responsive.borderRadius - 2),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.responsive.spacingSmall + 2,
                  vertical: widget.responsive.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius:
                      BorderRadius.circular(widget.responsive.borderRadius - 2),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.responsive.captionFontSize - 2,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContentSection() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        widget.responsive.contentPadding,
        widget.responsive.contentPadding - 4,
        widget.responsive.contentPadding,
        widget.responsive.contentPadding - 2,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft:
              Radius.circular(widget.responsive.cardRadius + 7),
          bottomRight:
              Radius.circular(widget.responsive.cardRadius + 7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            widget.route.displayTitle,
            style: TextStyle(
              fontSize: widget.responsive.subtitleFontSize,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.5,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.route.regionDisplay.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    size: widget.responsive.captionFontSize,
                    color: const Color(0xFF667EEA),
                  ),
                ),
                SizedBox(width: widget.responsive.spacingSmall - 2),
                Expanded(
                  child: Text(
                    widget.route.regionDisplay,
                    style: TextStyle(
                      fontSize: widget.responsive.captionFontSize,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          // Stats Row
          _buildStatsRow(),
          const SizedBox(height: 8),
          // Action Button - Only this triggers navigation
          _buildExploreButton(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.schedule_rounded,
            label: widget.route.formattedDuration,
            color: const Color(0xFF6366F1),
          ),
        ),
        Container(
          width: 1,
          height: 28,
          color: const Color(0xFFE2E8F0),
        ),
        Expanded(
          child: _buildStatItem(
            icon: Icons.place_rounded,
            label: AppLocalizations.of(context)!.placesCount(widget.route.placesCount),
            color: const Color(0xFF10B981),
          ),
        ),
        Container(
          width: 1,
          height: 28,
          color: const Color(0xFFE2E8F0),
        ),
        Expanded(
          child: _buildStatItem(
            icon: _getTransportIcon(widget.route.transportType),
            label: widget.route.transportLabel,
            color: const Color(0xFF3B82F6),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: widget.responsive.captionFontSize + 8,
            color: color,
          ),
        ),
        SizedBox(height: widget.responsive.spacingXS-1),
        Text(
          label,
          style: TextStyle(
            fontSize: widget.responsive.captionFontSize - 1,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF475569),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildExploreButton() {
    return Container(
      width: double.infinity,
      height: widget.responsive.buttonHeight - 4,
      decoration: BoxDecoration(
        gradient: widget.isLoading
            ? LinearGradient(
                colors: [
                  const Color(0xFF667EEA).withValues(alpha: 0.7),
                  const Color(0xFF764BA2).withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(widget.responsive.borderRadius + 4),
        boxShadow: widget.isLoading
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF667EEA).withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(widget.responsive.borderRadius + 4),
          onTap: widget.isLoading ? null : widget.onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.isLoading
                ? [
                    _buildPremiumLoadingIndicator(),
                    SizedBox(width: widget.responsive.spacingSmall),
                    Text(
                      AppLocalizations.of(context)!.preparingRoute,
                      style: TextStyle(
                        fontSize: widget.responsive.bodyFontSize - 1,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ]
                : [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.explore_rounded,
                        color: Colors.white,
                        size: widget.responsive.iconSize - 6,
                      ),
                    ),
                    SizedBox(width: widget.responsive.spacingSmall),
                    Text(
                      AppLocalizations.of(context)!.exploreRoute,
                      style: TextStyle(
                        fontSize: widget.responsive.bodyFontSize,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: widget.responsive.spacingSmall - 2),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: widget.responsive.iconSize - 6,
                    ),
                  ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumLoadingIndicator() {
    return SizedBox(
      width: widget.responsive.iconSize - 4,
      height: widget.responsive.iconSize - 4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer spinning ring
          SizedBox(
            width: widget.responsive.iconSize - 4,
            height: widget.responsive.iconSize - 4,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
          // Inner pulsing dot
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTransportIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'driving':
        return Icons.directions_car_rounded;
      case 'transit':
        return Icons.directions_bus_rounded;
      default:
        return Icons.directions_walk_rounded;
    }
  }

  String _getCategoryLabel(String category, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (category.toLowerCase()) {
      case 'historical':
        return l10n.categoryHistorical;
      case 'seaside':
        return l10n.categorySeaside;
      case 'mosque':
        return l10n.categoryMosque;
      case 'scenic':
        return l10n.categoryScenic;
      case 'local':
        return l10n.categoryLocal;
      case 'cafe':
        return l10n.categoryCafe;
      case 'restaurant':
        return l10n.categoryRestaurant;
      case 'park':
        return l10n.categoryPark;
      case 'museum':
        return l10n.categoryMuseum;
      case 'attraction':
        return l10n.categoryAttraction;
      default:
        return category.isNotEmpty
            ? category[0].toUpperCase() + category.substring(1)
            : category;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'historical':
        return Icons.account_balance_rounded;
      case 'seaside':
        return Icons.water_rounded;
      case 'mosque':
        return Icons.mosque_rounded;
      case 'scenic':
        return Icons.landscape_rounded;
      case 'local':
        return Icons.storefront_rounded;
      case 'cafe':
        return Icons.coffee_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'park':
        return Icons.park_rounded;
      case 'museum':
        return Icons.museum_rounded;
      case 'attraction':
        return Icons.attractions_rounded;
      default:
        return Icons.place_rounded;
    }
  }
}
