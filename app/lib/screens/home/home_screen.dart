import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../config/router.dart';
import '../../providers/home_navigation_provider.dart';
import '../advice-routes/advice_routes_screen.dart' show AdviceRoutesScreenContent;
import '../profile/profile_screen.dart' show ProfileScreenContent;
import '../saved-route/my_route_screen.dart' show MyRoutesScreenContent;
import '../route-results/route_results_screen.dart' show RouteResultsScreenContent;
import 'widgets/explore_tab_content.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(homeNavigationProvider);
    final selectedNavIndex = navState.selectedTabIndex;

    return Scaffold(
      backgroundColor: const Color(0xFFf6f7f8),
      body: IndexedStack(
        index: selectedNavIndex,
        children: [
          _buildExploreTab(),
          RouteResultsScreenContent(routeResult: navState.selectedRouteResult),
          const AdviceRoutesScreenContent(),
          const MyRoutesScreenContent(),
          const ProfileScreenContent(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildExploreTab() {
    return ExploreTabContent(
      onDurationTap: () {
        // TODO: Navigate to duration selection screen
      },
      onTransportTap: () {
        // TODO: Navigate to transport selection screen
      },
      onCreateRoute: () {
        // Navigate to route loading screen
        context.push(AppRoutes.routeLoading);
      },
      onAIButtonTap: () {
        // TODO: Open AI chat or quick generation
      },
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final navNotifier = ref.read(homeNavigationProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            icon: Icons.explore_outlined,
            activeIcon: Icons.explore_rounded,
            label: l10n.navExplore,
            index: 0,
            onTap: () => navNotifier.setTabIndex(0),
          ),
          _buildNavItem(
            icon: Icons.map_outlined,
            activeIcon: Icons.map_rounded,
            label: l10n.navRoutes,
            index: 1,
            onTap: () => navNotifier.setTabIndex(1),
          ),
          _buildNavItem(
            icon: Icons.auto_awesome_outlined,
            activeIcon: Icons.auto_awesome_rounded,
            label: l10n.navAdvice,
            index: 2,
            onTap: () => navNotifier.setTabIndex(2),
          ),
          _buildNavItem(
            icon: Icons.bookmark_outline_rounded,
            activeIcon: Icons.bookmark_rounded,
            label: l10n.navSaved,
            index: 3,
            onTap: () => navNotifier.setTabIndex(3),
          ),
          _buildNavItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: l10n.navProfile,
            index: 4,
            onTap: () => navNotifier.setTabIndex(4),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required VoidCallback onTap,
  }) {
    final selectedNavIndex = ref.watch(homeNavigationProvider).selectedTabIndex;
    final isSelected = selectedNavIndex == index;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: isSelected ? 1.0 : 0.0),
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 1.0 + (value * 0.1),
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    color: Color.lerp(
                      const Color(0xFF64748B),
                      Colors.white,
                      value,
                    ),
                    size: 24,
                  ),
                );
              },
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 100),
                opacity: isSelected ? 1.0 : 0.0,
                child: isSelected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
