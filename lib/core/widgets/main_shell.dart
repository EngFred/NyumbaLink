import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/notifications/presentation/providers/notifications_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  static const _tabs = ['/browse', '/saved', '/bookings', '/account'];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i])) return i;
    }
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    if (_currentIndex(context) == index) return;
    context.go(_tabs[index]);
  }

  Widget _buildTitle(int index) {
    if (index == 0) {
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Nyumba',
              style: AppTextStyles.h3.copyWith(color: AppColors.primary),
            ),
            TextSpan(
              text: 'Link',
              style: AppTextStyles.h3.copyWith(color: AppColors.accent),
            ),
          ],
        ),
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
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : unreadCount.toString(),
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
    final currentIndex = _currentIndex(context);

    return Scaffold(
      appBar: AppBar(
        title: _buildTitle(currentIndex),
        actions: _buildActions(context, ref, currentIndex),
      ),
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.grey200, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore,
                  label: 'Explore',
                  isActive: currentIndex == 0,
                  onTap: () => _onTap(context, 0),
                ),
                _NavItem(
                  icon: Icons.favorite_border_rounded,
                  activeIcon: Icons.favorite_rounded,
                  label: 'Saved',
                  isActive: currentIndex == 1,
                  onTap: () => _onTap(context, 1),
                ),
                _NavItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long_rounded,
                  label: 'Bookings',
                  isActive: currentIndex == 2,
                  onTap: () => _onTap(context, 2),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Account',
                  isActive: currentIndex == 3,
                  onTap: () => _onTap(context, 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.grey500;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary50 : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
