import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:rentora/core/widgets/nav_Item.dart';
import '../../features/notifications/presentation/providers/notifications_provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart'; // Adjust path if needed
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  @override
  void initState() {
    super.initState();
    // Safe post-frame execution ensures the UI renders cleanly before
    // verifying authenticated registration, preserving a premium user experience.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).initFcmToken();
    });
  }

  void _onTap(int index) {
    widget.navigationShell.goBranch(
      index,
      // When tapping the current tab again, go back to its initial location
      // (e.g. tapping Explore while already on Explore scrolls to top).
      initialLocation: index == widget.navigationShell.currentIndex,
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

  List<Widget> _buildActions(BuildContext context, int index) {
    final unreadCount = ref.watch(notificationsProvider).unreadCount;
    return [
      IconButton(
        icon: const Icon(Icons.help_outline_rounded),
        tooltip: 'Get Help or Report an Issue',
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
      // ── NEW FIX: Added a Gap here to give the right edge breathing room ──
      const Gap(8),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;
    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && currentIndex != 0) {
          widget.navigationShell.goBranch(0);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: _buildTitle(currentIndex),
          actions: _buildActions(context, currentIndex),
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.surface, // Forces pure white
          surfaceTintColor: Colors.transparent,
        ),
        body: widget.navigationShell,
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
