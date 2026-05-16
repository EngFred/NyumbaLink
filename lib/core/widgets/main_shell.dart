import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rentora/core/widgets/nav_Item.dart';

import '../../features/notifications/presentation/providers/notifications_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      // When tapping the current tab again, go back to its initial location
      // (e.g. tapping Explore while already on Explore scrolls to top).
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  Widget _buildTitle(int index) {
    if (index == 0) {
      return Image.asset(
        'assets/images/new_logo.png',
        height: 50,
        fit: BoxFit.contain,
      );
    }
    const titles = ['Explore', 'Saved', 'My Bookings', 'Account'];
    return Text(titles[index], style: AppTextStyles.h3);
  }

  List<Widget> _buildActions(BuildContext context, WidgetRef ref, int index) {
    final unreadCount = ref.watch(notificationsProvider).unreadCount;
    return [
      IconButton(
        icon: const Icon(Icons.feedback_outlined),
        tooltip: 'Report an issue',
        onPressed: () => context.push('/complaint'),
      ),
      if (index == 0)
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: () => context.push('/notifications'),
            ),
            if (unreadCount > 0)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 17,
                  height: 17,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = navigationShell.currentIndex;

    return PopScope(
      // Allow normal pop only when already on the Explore tab.
      // On any other tab, intercept and jump to Explore first.
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && currentIndex != 0) {
          navigationShell.goBranch(0);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: _buildTitle(currentIndex),
          actions: _buildActions(context, ref, currentIndex),
        ),
        body: navigationShell,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  NavItem(
                    icon: Icons.explore_outlined,
                    activeIcon: Icons.explore,
                    label: 'Explore',
                    isActive: currentIndex == 0,
                    onTap: () => _onTap(0),
                  ),
                  NavItem(
                    icon: Icons.favorite_border_rounded,
                    activeIcon: Icons.favorite_rounded,
                    label: 'Saved',
                    isActive: currentIndex == 1,
                    onTap: () => _onTap(1),
                  ),
                  NavItem(
                    icon: Icons.receipt_long_outlined,
                    activeIcon: Icons.receipt_long_rounded,
                    label: 'Bookings',
                    isActive: currentIndex == 2,
                    onTap: () => _onTap(2),
                  ),
                  NavItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: 'Account',
                    isActive: currentIndex == 3,
                    onTap: () => _onTap(3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
