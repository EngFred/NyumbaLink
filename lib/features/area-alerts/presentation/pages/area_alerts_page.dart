import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rentora/features/area-alerts/domain/entities/area_alert.dart';
import 'package:rentora/features/area-alerts/presentation/widgets/alert_tile.dart';

import '../../../../../core/services/notification_permission_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_snackbar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/area_alerts_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/unauthenticated_view.dart';
import '../widgets/add_area_sheet.dart';

class AreaAlertsPage extends ConsumerStatefulWidget {
  const AreaAlertsPage({super.key});

  @override
  ConsumerState<AreaAlertsPage> createState() => _AreaAlertsPageState();
}

class _AreaAlertsPageState extends ConsumerState<AreaAlertsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(authProvider).isAuthenticated) {
        ref.read(areaAlertsProvider.notifier).load();
      }
    });
  }

  /// Ensures notification permission is in place before subscribing to an area.
  ///
  /// Returns true if the caller can proceed, false if they should abort.
  Future<bool> _ensureNotificationPermission() async {
    // Already granted — nothing to do.
    if (await NotificationPermissionService.isGranted()) return true;

    // Not asked yet — request now. The user is actively trying to subscribe
    // so the reason is obvious and they're likely to accept.
    if (await NotificationPermissionService.isNotDetermined()) {
      await NotificationPermissionService.requestPermission();
      return NotificationPermissionService.isGranted();
    }

    // Denied — explain and offer a shortcut to Settings.
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
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add area'),
            )
          : null,
      body: !isAuth
          ? UnauthenticatedView(onLogin: _goToLogin)
          : state.isLoading && state.alerts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.alerts.isEmpty
          ? EmptyState(onAdd: () => _onAddAreaTapped(context))
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => ref.read(areaAlertsProvider.notifier).load(),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: state.alerts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return AlertTile(
                    alert: state.alerts[index],
                    onUnsubscribe: () => _unsubscribe(state.alerts[index]),
                  );
                },
              ),
            ),
    );
  }

  void _goToLogin() => context.go('/login');

  /// Called when the user taps "Add area" — checks permission first.
  Future<void> _onAddAreaTapped(BuildContext context) async {
    final allowed = await _ensureNotificationPermission();
    if (!allowed || !mounted) return;
    _showAddAreaSheet(context);
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
      await ref.read(areaAlertsProvider.notifier).unsubscribe(alert.areaId);
      if (mounted) {
        AppSnackbar.success(context, 'Removed alerts for ${alert.areaName}');
      }
    }
  }

  void _showAddAreaSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddAreaSheet(),
    );
  }
}
