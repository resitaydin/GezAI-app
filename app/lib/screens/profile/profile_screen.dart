import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../config/router.dart';
import '../../providers/auth_provider.dart';
import '../../utils/responsive_utils.dart';

/// Content-only version for embedding in tab navigation
class ProfileScreenContent extends ConsumerWidget {
  const ProfileScreenContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final user = authService.currentUser;
    final responsive = ResponsiveUtils.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFF1F5F9),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, ref, responsive),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.pagePaddingHorizontal,
                ),
                child: Column(
                  children: [
                    _buildProfileHeader(user, responsive),
                    SizedBox(height: responsive.spacingLarge),
                    _buildStatsSection(responsive),
                    SizedBox(height: responsive.spacingMedium),
                    _buildMenuSection(context, ref, responsive),
                    SizedBox(height: responsive.spacingXL + 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, WidgetRef ref, ResponsiveUtils responsive) {
    final l10n = AppLocalizations.of(context)!;
    final logoutButtonSize = responsive.valueByScreenSize(
      compact: 40.0,
      regular: 44.0,
      tall: 48.0,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        responsive.pagePaddingHorizontal,
        responsive.spacingSmall,
        responsive.pagePaddingHorizontal,
        responsive.spacingSmall,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.profileTitle,
            style: TextStyle(
              fontSize: responsive.subtitleFontSize + 4,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          Container(
            width: logoutButtonSize,
            height: logoutButtonSize,
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
                onTap: () => _showLogoutConfirmation(context, ref, responsive),
                child: Icon(
                  Icons.logout_rounded,
                  color: const Color(0xFFEF4444),
                  size: logoutButtonSize * 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user, ResponsiveUtils responsive) {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final displayName = user?.displayName ?? l10n.profileDefaultName;
        final email = user?.email ?? '';
        final photoUrl = user?.photoURL;
        final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'T';

        final avatarSize = responsive.valueByScreenSize(
          compact: 80.0,
          regular: 90.0,
          tall: 100.0,
        );

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: photoUrl != null
                      ? Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildAvatarPlaceholder(initial, responsive);
                          },
                        )
                      : _buildAvatarPlaceholder(initial, responsive),
                ),
              ),
            ),
            SizedBox(height: responsive.spacingMedium),
            Text(
              displayName,
              style: TextStyle(
                fontSize: responsive.subtitleFontSize + 2,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: responsive.spacingXS),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mail_outline_rounded,
                  size: responsive.captionFontSize + 2,
                  color: const Color(0xFF64748B).withValues(alpha: 0.8),
                ),
                const SizedBox(width: 6),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: responsive.captionFontSize + 1,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B).withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildAvatarPlaceholder(String initial, ResponsiveUtils responsive) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: responsive.titleFontSize,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(ResponsiveUtils responsive) {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final iconSize = responsive.valueByScreenSize(
          compact: 40.0,
          regular: 44.0,
          tall: 48.0,
        );

        return Container(
          padding: EdgeInsets.symmetric(
            vertical: responsive.spacingMedium,
            horizontal: responsive.contentPadding,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(responsive.cardRadius),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E3A5F).withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                context: context,
                icon: Icons.route_rounded,
                value: '0',
                label: l10n.profileStatsRoutes,
                gradient: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                iconSize: iconSize,
                responsive: responsive,
              ),
              _buildStatDivider(responsive),
              _buildStatItem(
                context: context,
                icon: Icons.bookmark_rounded,
                value: '0',
                label: l10n.profileStatsSaved,
                gradient: const [Color(0xFF10B981), Color(0xFF34D399)],
                iconSize: iconSize,
                responsive: responsive,
              ),
              _buildStatDivider(responsive),
              _buildStatItem(
                context: context,
                icon: Icons.explore_rounded,
                value: '0',
                label: l10n.profileStatsExplored,
                gradient: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                iconSize: iconSize,
                responsive: responsive,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
    required List<Color> gradient,
    required double iconSize,
    required ResponsiveUtils responsive,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                gradient[0].withValues(alpha: 0.15),
                gradient[1].withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(responsive.borderRadius),
          ),
          child: Icon(icon, color: gradient[0], size: iconSize * 0.5),
        ),
        SizedBox(height: responsive.spacingSmall),
        Text(
          value,
          style: TextStyle(
            fontSize: responsive.subtitleFontSize,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: responsive.captionFontSize,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B).withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(ResponsiveUtils responsive) {
    return Container(
      width: 1,
      height: responsive.valueByScreenSize(compact: 50.0, regular: 55.0, tall: 60.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFE2E8F0).withValues(alpha: 0),
            const Color(0xFFE2E8F0),
            const Color(0xFFE2E8F0).withValues(alpha: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, WidgetRef ref, ResponsiveUtils responsive) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(responsive.cardRadius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A5F).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMenuItem(
            icon: Icons.person_outline_rounded,
            label: l10n.profileMenuEditProfile,
            iconGradient: const [Color(0xFF3B82F6), Color(0xFF60A5FA)],
            responsive: responsive,
            onTap: () => _showComingSoon(context, l10n.profileMenuEditProfile),
          ),
          _buildMenuDivider(responsive),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            label: l10n.profileMenuNotifications,
            iconGradient: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
            responsive: responsive,
            onTap: () => _showComingSoon(context, l10n.profileMenuNotifications),
          ),
          _buildMenuDivider(responsive),
          _buildMenuItem(
            icon: Icons.language_rounded,
            label: l10n.profileMenuLanguage,
            trailing: l10n.profileMenuLanguageTrailing,
            iconGradient: const [Color(0xFF10B981), Color(0xFF34D399)],
            responsive: responsive,
            onTap: () => _showComingSoon(context, l10n.profileMenuLanguage),
          ),
          _buildMenuDivider(responsive),
          _buildMenuItem(
            icon: Icons.help_outline_rounded,
            label: l10n.profileMenuHelp,
            iconGradient: const [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
            responsive: responsive,
            onTap: () => _showComingSoon(context, l10n.profileMenuHelp),
          ),
          _buildMenuDivider(responsive),
          _buildMenuItem(
            icon: Icons.info_outline_rounded,
            label: l10n.profileMenuAbout,
            iconGradient: const [Color(0xFF64748B), Color(0xFF94A3B8)],
            responsive: responsive,
            onTap: () => _showAboutDialog(context, responsive),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    String? trailing,
    required List<Color> iconGradient,
    required ResponsiveUtils responsive,
    required VoidCallback onTap,
  }) {
    final iconContainerSize = responsive.valueByScreenSize(
      compact: 38.0,
      regular: 40.0,
      tall: 44.0,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(responsive.borderRadius),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.contentPadding,
            vertical: responsive.spacingSmall + 2,
          ),
          child: Row(
            children: [
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      iconGradient[0].withValues(alpha: 0.15),
                      iconGradient[1].withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(responsive.borderRadius - 2),
                ),
                child: Icon(icon, color: iconGradient[0], size: iconContainerSize * 0.5),
              ),
              SizedBox(width: responsive.spacingSmall + 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: responsive.bodyFontSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              if (trailing != null) ...[
                Text(
                  trailing,
                  style: TextStyle(
                    fontSize: responsive.captionFontSize + 1,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B).withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFF94A3B8).withValues(alpha: 0.8),
                size: responsive.iconSize - 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuDivider(ResponsiveUtils responsive) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.contentPadding),
      child: Container(
        height: 1,
        color: const Color(0xFFF1F5F9),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(l10n.profileComingSoon(feature)),
          ],
        ),
        backgroundColor: const Color(0xFF2563EB),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, ResponsiveUtils responsive) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(responsive.spacingLarge),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(responsive.cardRadius + 4),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: responsive.iconSizeLarge + 16,
                height: responsive.iconSizeLarge + 16,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(responsive.borderRadius + 4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.explore_rounded,
                  color: Colors.white,
                  size: responsive.iconSizeLarge - 8,
                ),
              ),
              SizedBox(height: responsive.spacingMedium),
              Text(
                'GezAI',
                style: TextStyle(
                  fontSize: responsive.titleFontSize,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: responsive.spacingXS),
              Text(
                l10n.profileAboutVersion,
                style: TextStyle(
                  fontSize: responsive.captionFontSize + 1,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B).withValues(alpha: 0.9),
                ),
              ),
              SizedBox(height: responsive.spacingMedium),
              Text(
                l10n.profileAboutDescription,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: responsive.bodyFontSize,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF475569),
                  height: 1.5,
                ),
              ),
              SizedBox(height: responsive.spacingLarge),
              SizedBox(
                width: double.infinity,
                height: responsive.buttonHeight - 4,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(responsive.borderRadius),
                    ),
                  ),
                  child: Text(
                    l10n.profileAboutButton,
                    style: TextStyle(
                      fontSize: responsive.bodyFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref, ResponsiveUtils responsive) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: responsive.pagePaddingHorizontal),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(responsive.cardRadius + 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: responsive.spacingLarge),
              Container(
                width: responsive.iconSizeLarge + 24,
                height: responsive.iconSizeLarge + 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E6),
                  borderRadius: BorderRadius.circular(responsive.cardRadius),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: const Color(0xFFEF4444),
                  size: responsive.iconSizeLarge,
                ),
              ),
              SizedBox(height: responsive.spacingMedium),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.pagePaddingHorizontal),
                child: Text(
                  l10n.profileLogoutTitle,
                  style: TextStyle(
                    fontSize: responsive.subtitleFontSize + 2,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              SizedBox(height: responsive.spacingSmall),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.pagePaddingHorizontal),
                child: Text(
                  l10n.profileLogoutMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: responsive.bodyFontSize,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: responsive.spacingLarge),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  responsive.contentPadding,
                  0,
                  responsive.contentPadding,
                  responsive.spacingMedium,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: responsive.buttonHeight,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(responsive.borderRadius + 2),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(responsive.borderRadius + 2),
                            onTap: () => Navigator.pop(dialogContext),
                            child: Center(
                              child: Text(
                                l10n.profileLogoutCancel,
                                style: TextStyle(
                                  fontSize: responsive.bodyFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: responsive.spacingSmall),
                    Expanded(
                      child: Container(
                        height: responsive.buttonHeight,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(responsive.borderRadius + 2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(responsive.borderRadius + 2),
                            onTap: () async {
                              Navigator.pop(dialogContext);
                              await ref.read(authControllerProvider.notifier).signOut();
                              if (context.mounted) {
                                context.go(AppRoutes.login);
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  color: Colors.white,
                                  size: responsive.iconSize - 4,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.profileLogoutConfirm,
                                  style: TextStyle(
                                    fontSize: responsive.bodyFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
