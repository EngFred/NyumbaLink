import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_snackbar.dart';
import '../../data/datasources/area_alerts_remote_datasource.dart';
import '../../data/models/area_option.dart';
import '../providers/area_alerts_provider.dart';

class AddAreaSheet extends ConsumerStatefulWidget {
  const AddAreaSheet({super.key});

  @override
  ConsumerState<AddAreaSheet> createState() => _AddAreaSheetState();
}

class _AddAreaSheetState extends ConsumerState<AddAreaSheet> {
  List<AreaOption> _allAreas = [];
  bool _loading = true;
  String _search = '';

  // UI Polish: Track which item is currently being saved to show an inline spinner
  String? _subscribingId;

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
                      "You'll get notified when a new property is listed there.",
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Gap(14),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search areas…',
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: AppColors.grey400,
                        ),
                        filled: true,
                        fillColor: AppColors
                            .background, // Slight contrast from the surface
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
              const Gap(16),
              const Divider(height: 1, color: AppColors.grey200),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : grouped.isEmpty
                    ? const Center(
                        child: Text(
                          'No areas found',
                          style: TextStyle(color: AppColors.grey400),
                        ),
                      )
                    : ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.only(bottom: 32),
                        children: grouped.entries.expand((entry) {
                          return [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                              child: Text(
                                entry.key
                                    .toUpperCase(), // Uppercase header for distinct visual hierarchy
                                style: AppTextStyles.labelMd.copyWith(
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            ...entry.value.map((area) {
                              final isSubscribed = subscribedIds.contains(
                                area.id,
                              );
                              final isSubscribing = _subscribingId == area.id;

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
                                  size: 24,
                                ),
                                title: Text(
                                  area.name,
                                  style: AppTextStyles.bodyMd.copyWith(
                                    fontWeight: isSubscribed
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),

                                // UI Polish: Dynamic Trailing state
                                trailing: isSubscribing
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : isSubscribed
                                    ? Text(
                                        'Subscribed',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.add_rounded,
                                        color: AppColors.grey400,
                                        size: 24,
                                      ),

                                onTap: isSubscribed || _subscribingId != null
                                    ? null
                                    : () async {
                                        // 1. Set the loading UI state
                                        setState(
                                          () => _subscribingId = area.id,
                                        );

                                        // 2. Await the network call
                                        await ref
                                            .read(areaAlertsProvider.notifier)
                                            .subscribe(area.id);

                                        // 3. Check if it succeeded by looking at the updated state
                                        final success = ref
                                            .read(areaAlertsProvider)
                                            .alerts
                                            .any((a) => a.areaId == area.id);

                                        if (mounted) {
                                          if (success) {
                                            // Smooth closing sequence
                                            Navigator.pop(context);
                                            AppSnackbar.success(
                                              context,
                                              'Alerts enabled for ${area.name}',
                                            );
                                          } else {
                                            // If failed, remove loading state (error handled by listener in parent)
                                            setState(
                                              () => _subscribingId = null,
                                            );
                                          }
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
