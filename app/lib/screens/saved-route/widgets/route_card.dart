import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../models/route_model.dart';
import '../../../utils/responsive_utils.dart';
import '../../../l10n/app_localizations.dart';

class RouteCard extends StatelessWidget {
  final SavedRouteListItem route;
  final VoidCallback? onRemove;
  final VoidCallback? onViewDetails;

  const RouteCard({
    super.key,
    required this.route,
    this.onRemove,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveUtils.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(responsive.cardRadius + 8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A5F).withValues(alpha: 0.06),
            blurRadius: responsive.valueByScreenSize(
              compact: 24.0,
              regular: 32.0,
              tall: 40.0,
            ),
            offset: Offset(0, responsive.spacingSmall),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF1E3A5F).withValues(alpha: 0.04),
            blurRadius: responsive.spacingSmall,
            offset: Offset(0, responsive.spacingXS),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(responsive.cardRadius + 7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(responsive, context),
            _buildContentSection(responsive, context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(ResponsiveUtils responsive, BuildContext context) {
    final imageHeight = responsive.valueByScreenSize(
      veryCompact: 120.0,
      compact: 140.0,
      regular: 160.0,
      tall: 180.0,
    );

    return Stack(
      children: [
        ClipRRect(
          child: route.thumbnailUrl != null
              ? Stack(
                  children: [
                    Image.network(
                      route.thumbnailUrl!,
                      height: imageHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildGradientPlaceholder(imageHeight, responsive);
                      },
                    ),
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
              : _buildGradientPlaceholder(imageHeight, responsive),
        ),
        // Transport type badge (top right)
        if (route.transportType != null)
          Positioned(
            top: responsive.spacingSmall,
            right: responsive.spacingSmall,
            child: _buildTransportBadge(responsive, context),
          ),
        // Saved date badge (bottom left)
        Positioned(
          bottom: responsive.spacingSmall,
          left: responsive.spacingSmall,
          child: _buildSavedDateBadge(responsive),
        ),
      ],
    );
  }

  Widget _buildGradientPlaceholder(double height, ResponsiveUtils responsive) {
    final iconContainerSize = responsive.valueByScreenSize(
      veryCompact: 40.0,
      compact: 48.0,
      regular: 56.0,
      tall: 64.0,
    );

    final decorCircleLarge = responsive.valueByScreenSize(
      veryCompact: 80.0,
      compact: 100.0,
      regular: 110.0,
      tall: 120.0,
    );

    final decorCircleSmall = responsive.valueByScreenSize(
      veryCompact: 50.0,
      compact: 65.0,
      regular: 75.0,
      tall: 80.0,
    );

    final gradientHeight = responsive.valueByScreenSize(
      veryCompact: 35.0,
      compact: 40.0,
      regular: 45.0,
      tall: 50.0,
    );

    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3B82F6),
            Color(0xFF1D4ED8),
            Color(0xFF1E40AF),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -decorCircleLarge * 0.25,
            right: -decorCircleLarge * 0.25,
            child: Container(
              width: decorCircleLarge,
              height: decorCircleLarge,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -decorCircleSmall * 0.25,
            left: -decorCircleSmall * 0.25,
            child: Container(
              width: decorCircleSmall,
              height: decorCircleSmall,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Center(
            child: Container(
              width: iconContainerSize,
              height: iconContainerSize,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(responsive.borderRadius),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.map_rounded,
                color: Colors.white,
                size: iconContainerSize * 0.5,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: gradientHeight,
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

  Widget _buildTransportBadge(ResponsiveUtils responsive, BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(responsive.borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.spacingSmall,
            vertical: responsive.spacingXS,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(responsive.borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getTransportIcon(route.transportType!),
                color: Colors.white,
                size: responsive.captionFontSize + 2,
              ),
              SizedBox(width: responsive.spacingXS),
              Text(
                _getTransportLabel(route.transportType!, context),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: responsive.captionFontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavedDateBadge(ResponsiveUtils responsive) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(responsive.borderRadius - 2),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.spacingSmall,
            vertical: responsive.spacingXS,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(responsive.borderRadius - 2),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bookmark_rounded,
                color: Colors.white,
                size: responsive.captionFontSize,
              ),
              SizedBox(width: responsive.spacingXS),
              Text(
                route.formattedSavedDate,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: responsive.captionFontSize - 1,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTransportIcon(String type) {
    switch (type.toLowerCase()) {
      case 'driving':
        return Icons.directions_car_rounded;
      case 'transit':
        return Icons.directions_bus_rounded;
      default:
        return Icons.directions_walk_rounded;
    }
  }

  String _getTransportLabel(String type, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (type.toLowerCase()) {
      case 'driving':
        return l10n.transportDrive;
      case 'transit':
        return l10n.transportTransit;
      default:
        return l10n.transportWalk;
    }
  }

  Widget _buildContentSection(ResponsiveUtils responsive, BuildContext context) {
    final verticalSpacing = responsive.valueByScreenSize(
      veryCompact: 6.0,
      compact: 8.0,
      regular: 10.0,
      tall: 12.0,
    );

    return Container(
      padding: EdgeInsets.all(responsive.contentPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(responsive.cardRadius + 7),
          bottomRight: Radius.circular(responsive.cardRadius + 7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            route.displayTitle,
            style: TextStyle(
              fontSize: responsive.subtitleFontSize,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.5,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (route.regionDisplay.isNotEmpty) ...[
            SizedBox(height: responsive.spacingXS),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(responsive.spacingXS - 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(responsive.spacingXS),
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    size: responsive.captionFontSize,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
                SizedBox(width: responsive.spacingSmall - 2),
                Expanded(
                  child: Text(
                    route.regionDisplay,
                    style: TextStyle(
                      fontSize: responsive.captionFontSize,
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
          SizedBox(height: verticalSpacing),
          // Stats Row
          _buildStatsRow(responsive, context),
          SizedBox(height: verticalSpacing),
          // Action Buttons
          _buildActionButtons(responsive, context),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ResponsiveUtils responsive, BuildContext context) {
    final dividerHeight = responsive.valueByScreenSize(
      veryCompact: 22.0,
      compact: 24.0,
      regular: 28.0,
      tall: 32.0,
    );

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.schedule_rounded,
            label: route.formattedDuration,
            color: const Color(0xFF6366F1),
            responsive: responsive,
          ),
        ),
        Container(
          width: 1,
          height: dividerHeight,
          color: const Color(0xFFE2E8F0),
        ),
        Expanded(
          child: _buildStatItem(
            icon: Icons.place_rounded,
            label: AppLocalizations.of(context)!.placesCount(route.placesCount),
            color: const Color(0xFF10B981),
            responsive: responsive,
          ),
        ),
        Container(
          width: 1,
          height: dividerHeight,
          color: const Color(0xFFE2E8F0),
        ),
        Expanded(
          child: _buildStatItem(
            icon: Icons.calendar_today_rounded,
            label: route.formattedPlannedDate,
            color: const Color(0xFFF59E0B),
            responsive: responsive,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required Color color,
    required ResponsiveUtils responsive,
  }) {
    final iconContainerPadding = responsive.valueByScreenSize(
      veryCompact: 4.0,
      compact: 5.0,
      regular: 6.0,
      tall: 7.0,
    );

    final iconSize = responsive.valueByScreenSize(
      veryCompact: responsive.captionFontSize + 3,
      compact: responsive.captionFontSize + 4,
      regular: responsive.captionFontSize + 6,
      tall: responsive.captionFontSize + 8,
    );

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(iconContainerPadding),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(responsive.spacingSmall),
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: color,
          ),
        ),
        SizedBox(height: responsive.spacingXS - 1),
        Text(
          label,
          style: TextStyle(
            fontSize: responsive.captionFontSize - 1,
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

  Widget _buildActionButtons(ResponsiveUtils responsive, BuildContext context) {
    final buttonHeight = responsive.valueByScreenSize(
      veryCompact: 40.0,
      compact: 44.0,
      regular: 48.0,
      tall: 52.0,
    );

    final iconContainerPadding = responsive.valueByScreenSize(
      veryCompact: 4.0,
      compact: 4.0,
      regular: 5.0,
      tall: 6.0,
    );

    return Row(
      children: [
        // View Details Button
        Expanded(
          child: Container(
            height: buttonHeight,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(responsive.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
                  blurRadius: responsive.spacingSmall,
                  offset: Offset(0, responsive.spacingXS),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(responsive.borderRadius),
                onTap: onViewDetails,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(iconContainerPadding),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(responsive.spacingXS + 1),
                      ),
                      child: Icon(
                        Icons.map_rounded,
                        color: Colors.white,
                        size: responsive.iconSize - 6,
                      ),
                    ),
                    SizedBox(width: responsive.spacingSmall),
                    Text(
                      AppLocalizations.of(context)!.viewRoute,
                      style: TextStyle(
                        fontSize: responsive.bodyFontSize - 1,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(width: responsive.spacingXS),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: responsive.iconSize - 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: responsive.spacingSmall),
        // Delete Button
        Container(
          width: buttonHeight,
          height: buttonHeight,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE4E6),
            borderRadius: BorderRadius.circular(responsive.borderRadius),
            border: Border.all(
              color: const Color(0xFFFECACA),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(responsive.borderRadius),
              onTap: onRemove,
              child: Icon(
                Icons.delete_outline_rounded,
                color: const Color(0xFFF43F5E),
                size: responsive.iconSize - 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
