import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_snackbar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/area_alerts_remote_datasource.dart';
import '../../domain/entities/area_alert.dart';
import '../providers/area_alerts_provider.dart';

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
              onPressed: () => _showAddAreaSheet(context),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add area'),
            )
          : null,
      body: !isAuth
          ? _UnauthenticatedView(onLogin: () => context.go('/login'))
          : state.isLoading && state.alerts.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : state.alerts.isEmpty
          ? _EmptyState(onAdd: () => _showAddAreaSheet(context))
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => ref.read(areaAlertsProvider.notifier).load(),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: state.alerts.length,
                separatorBuilder: (_, __) => const Gap(10),
                itemBuilder: (context, index) {
                  return _AlertTile(
                        alert: state.alerts[index],
                        onUnsubscribe: () => _unsubscribe(state.alerts[index]),
                      )
                      .animate(
                        delay: Duration(
                          milliseconds: index < 8 ? index * 40 : 0,
                        ),
                      )
                      .fadeIn(duration: 260.ms)
                      .slideY(begin: 0.04, end: 0);
                },
              ),
            ),
    );
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
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
      builder: (_) => const _AddAreaSheet(),
    );
  }
}

// ── Subscription tile ─────────────────────────────────────────────────────────
class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert, required this.onUnsubscribe});

  final AreaAlert alert;
  final VoidCallback onUnsubscribe;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.notifications_active_outlined,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(alert.areaName, style: AppTextStyles.labelLg),
        subtitle: Text(
          alert.districtName,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: AppColors.error,
            size: 22,
          ),
          onPressed: onUnsubscribe,
        ),
      ),
    );
  }
}

// ── Add Area bottom sheet ─────────────────────────────────────────────────────
class _AddAreaSheet extends ConsumerStatefulWidget {
  const _AddAreaSheet();

  @override
  ConsumerState<_AddAreaSheet> createState() => _AddAreaSheetState();
}

class _AddAreaSheetState extends ConsumerState<_AddAreaSheet> {
  List<AreaOption> _allAreas = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  Future<void> _loadAreas() async {
    try {
      final ds = ref.read(areaAlertsRemoteDataSourceProvider);
      final areas = await ds.getAllAreas();
      if (mounted) {
        setState(() {
          _allAreas = areas;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscribedIds = ref
        .watch(areaAlertsProvider)
        .alerts
        .map((a) => a.areaId)
        .toSet();

    final filtered = _search.isEmpty
        ? _allAreas
        : _allAreas
              .where(
                (a) =>
                    a.name.toLowerCase().contains(_search.toLowerCase()) ||
                    a.districtName.toLowerCase().contains(
                      _search.toLowerCase(),
                    ),
              )
              .toList();

    final Map<String, List<AreaOption>> grouped = {};
    for (final area in filtered) {
      grouped.putIfAbsent(area.districtName, () => []).add(area);
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Choose an area', style: AppTextStyles.h4),
                    const Gap(4),
                    Text(
                      'You\'ll get notified when a new property is listed there.',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Gap(14),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search areas…',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (v) => setState(() => _search = v),
                    ),
                  ],
                ),
              ),
              const Gap(8),
              const Divider(height: 1, color: AppColors.grey200),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : grouped.isEmpty
                    ? const Center(child: Text('No areas found'))
                    : ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.only(bottom: 32),
                        children: grouped.entries.expand((entry) {
                          return [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
                              child: Text(
                                entry.key,
                                style: AppTextStyles.labelMd.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            ...entry.value.map((area) {
                              final isSubscribed = subscribedIds.contains(
                                area.id,
                              );
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 2,
                                ),
                                leading: Icon(
                                  isSubscribed
                                      ? Icons.check_circle_rounded
                                      : Icons.location_on_outlined,
                                  color: isSubscribed
                                      ? AppColors.primary
                                      : AppColors.grey400,
                                  size: 22,
                                ),
                                title: Text(
                                  area.name,
                                  style: AppTextStyles.bodyMd,
                                ),
                                trailing: isSubscribed
                                    ? Text(
                                        'Subscribed',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.add_rounded,
                                        color: AppColors.grey400,
                                        size: 20,
                                      ),
                                onTap: isSubscribed
                                    ? null
                                    : () async {
                                        Navigator.pop(context);
                                        await ref
                                            .read(areaAlertsProvider.notifier)
                                            .subscribe(area.id);
                                        if (context.mounted) {
                                          AppSnackbar.success(
                                            context,
                                            'Alerts enabled for ${area.name}',
                                          );
                                        }
                                      },
                              );
                            }),
                          ];
                        }).toList(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gap(20), // Extra top space for better balance
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons
                    .notifications_none_rounded, // Changed to match screenshot better
                color: AppColors.primary,
                size: 46,
              ),
            ),
            const Gap(32),
            Text(
              'No area alerts yet',
              style: AppTextStyles.h4,
              textAlign: TextAlign.center,
            ),
            const Gap(12),
            Text(
              'Add an area to get notified when new properties are listed there.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const Gap(48),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Add an area'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ),
            const Gap(80), // Bottom spacing to prevent floating button overlap
          ],
        ),
      ),
    );
  }
}

// ── Unauthenticated view ──────────────────────────────────────────────────────
class _UnauthenticatedView extends StatelessWidget {
  const _UnauthenticatedView({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 48,
              color: AppColors.grey400,
            ),
            const Gap(16),
            Text('Sign in required', style: AppTextStyles.h4),
            const Gap(8),
            Text(
              'Log in to manage your area notification alerts.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const Gap(24),
            ElevatedButton(onPressed: onLogin, child: const Text('Sign In')),
          ],
        ),
      ),
    );
  }
}
