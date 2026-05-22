import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/services/notification_permission_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_snackbar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/area_alert.dart';
import '../providers/area_alerts_provider.dart';
import '../widgets/alert_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/unauthenticated_view.dart';

class AreaAlertsPage extends ConsumerStatefulWidget {
  const AreaAlertsPage({super.key});

  @override
  ConsumerState<AreaAlertsPage> createState() => _AreaAlertsPageState();
}

class _AreaAlertsPageState extends ConsumerState<AreaAlertsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  // Track which item is currently being deleted for inline spinner
  String? _deletingId;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(authProvider).isAuthenticated) {
        ref.read(areaAlertsProvider.notifier).load();
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<bool> _ensureNotificationPermission() async {
    if (await NotificationPermissionService.isGranted()) return true;

    if (await NotificationPermissionService.isNotDetermined()) {
      await NotificationPermissionService.requestPermission();
      return NotificationPermissionService.isGranted();
    }

    if (!mounted) return false;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Notifications blocked', style: AppTextStyles.h4),
        content: Text(
          'To receive alerts when new properties are listed in this area, '
          'please enable notifications for Rentora in your device settings.',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Not now'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              NotificationPermissionService.openSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isAuth = ref.watch(authProvider).isAuthenticated;
    final state = ref.watch(areaAlertsProvider);

    ref.listen<AreaAlertsState>(areaAlertsProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        AppSnackbar.error(context, next.error!);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text('Notification Alerts', style: AppTextStyles.h4),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.grey200),
        ),
      ),
      floatingActionButton: isAuth
          ? FloatingActionButton.extended(
              onPressed: () => _onAddAreaTapped(context),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 2,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Add area',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            )
          : null,
      body: !isAuth
          ? UnauthenticatedView(onLogin: _goToLogin)
          : state.isLoading && state.alerts.isEmpty
          ? _buildSkeletonList()
          : state.alerts.isEmpty
          ? EmptyState(onAdd: () => _onAddAreaTapped(context))
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => ref.read(areaAlertsProvider.notifier).load(),
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: state.alerts.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  color: AppColors.grey200,
                  indent: 64,
                ),
                itemBuilder: (context, index) {
                  final alert = state.alerts[index];
                  return AlertTile(
                    alert: alert,
                    isDeleting: _deletingId == alert.areaId,
                    // If something is currently deleting, disable all other trash icons
                    onUnsubscribe: _deletingId != null
                        ? null
                        : () => _unsubscribe(alert),
                    // ── NEW: Open sheet in edit mode ─────────────────────────
                    onTap: () {
                      context.push(
                        '/add-area-alert',
                        extra: alert,
                      ); // Edit mode
                    },
                  );
                },
              ),
            ),
    );
  }

  Widget _buildSkeletonList() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Opacity(
          opacity: 0.4 + (_shimmerController.value * 0.6),
          child: ListView.separated(
            padding: const EdgeInsets.only(top: 16),
            itemCount: 6,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.grey200, indent: 64),
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: AppColors.grey200,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.grey200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 80,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.grey200,
                            borderRadius: BorderRadius.circular(4),
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
      },
    );
  }

  void _goToLogin() => context.go('/login');

  Future<void> _onAddAreaTapped(BuildContext context) async {
    final allowed = await _ensureNotificationPermission();
    if (!allowed || !mounted) return;
    context.push('/add-area-alert');
  }

  Future<void> _unsubscribe(AreaAlert alert) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Remove alert?', style: AppTextStyles.h4),
        content: Text(
          'You will stop receiving notifications for new listings in ${alert.areaName}.',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // 1. Show the inline spinner on the tile
      setState(() => _deletingId = alert.areaId);

      // 2. Perform the unsubscription
      await ref.read(areaAlertsProvider.notifier).unsubscribe(alert.areaId);

      if (mounted) {
        // 3. Reset the spinner state
        setState(() => _deletingId = null);

        // 4. Check if it was successfully removed from state before showing success
        final stillExists = ref
            .read(areaAlertsProvider)
            .alerts
            .any((a) => a.areaId == alert.areaId);
        if (!stillExists) {
          AppSnackbar.success(context, 'Removed alerts for ${alert.areaName}');
        }
      }
    }
  }
}
