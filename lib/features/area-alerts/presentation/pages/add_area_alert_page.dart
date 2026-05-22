import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:rentora/features/area-alerts/presentation/widgets/area_search_modal.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../data/models/area_option.dart';
import '../../domain/entities/area_alert.dart';
import '../providers/area_alerts_provider.dart';
import '../widgets/property_type_selector.dart';

class AddAreaAlertPage extends ConsumerStatefulWidget {
  const AddAreaAlertPage({super.key, this.existingAlert});

  final AreaAlert? existingAlert;

  @override
  ConsumerState<AddAreaAlertPage> createState() => _AddAreaAlertPageState();
}

class _AddAreaAlertPageState extends ConsumerState<AddAreaAlertPage> {
  AreaOption? _selectedArea;
  final Set<String> _selectedTypes = {};
  bool _isSubmitting = false;

  bool get _isEditing => widget.existingAlert != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final alert = widget.existingAlert!;
      _selectedArea = AreaOption(
        id: alert.areaId,
        name: alert.areaName,
        districtId: '',
        districtName: alert.districtName,
      );
      if (alert.propertyTypes != null) {
        _selectedTypes.addAll(alert.propertyTypes!);
      }
    }
  }

  Future<void> _submit() async {
    if (_selectedArea == null) return;

    setState(() => _isSubmitting = true);

    final types = _selectedTypes.isEmpty ? null : _selectedTypes.toList();

    if (_isEditing) {
      await ref
          .read(areaAlertsProvider.notifier)
          .updateAlert(_selectedArea!.id, propertyTypes: types);
    } else {
      await ref
          .read(areaAlertsProvider.notifier)
          .subscribe(_selectedArea!.id, propertyTypes: types);
    }

    if (mounted) context.pop();
  }

  Future<void> _openAreaSearch() async {
    if (_isEditing) return; // Prevent changing area when editing

    final selected = await showModalBottomSheet<AreaOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AreaSearchModal(initialArea: _selectedArea),
    );

    if (selected != null && mounted) {
      setState(() => _selectedArea = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          _isEditing ? 'Edit Alert' : 'Create Alert',
          style: AppTextStyles.h4,
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.grey200),
        ),
      ),
      // ── Dedicated bottom nav bar fixes the huge spacing issue ──
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          MediaQuery.of(context).padding.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: FilledButton(
          onPressed: (_selectedArea == null || _isSubmitting) ? null : _submit,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  _isEditing ? 'Save Changes' : 'Save Alert',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        children: [
          Text(
            _isEditing
                ? 'Update the property types for this area.'
                : 'Get notified the moment a space is listed.',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Gap(32),

          // ── Step 1: Area Selection ─────────────────────────────────
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _isEditing ? AppColors.grey400 : AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '1',
                  style: AppTextStyles.labelSm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Gap(12),
              Text(
                'Which area?',
                style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Gap(16),

          GestureDetector(
            onTap: _openAreaSearch,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: _isEditing ? AppColors.grey50 : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (_selectedArea != null && !_isEditing)
                      ? AppColors.primary
                      : AppColors.grey300,
                  width: (_selectedArea != null && !_isEditing) ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: _selectedArea != null
                        ? (_isEditing ? AppColors.grey500 : AppColors.primary)
                        : AppColors.grey500,
                    size: 24,
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedArea?.name ??
                              'Tap to search & select an area',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: _selectedArea != null
                                ? AppColors.textPrimary
                                : AppColors.textHint,
                            fontWeight: _selectedArea != null
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        if (_selectedArea != null) ...[
                          const Gap(2),
                          Text(
                            _selectedArea!.districtName,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!_isEditing)
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppColors.grey400,
                    )
                  else
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 16,
                      color: AppColors.grey400,
                    ),
                ],
              ),
            ),
          ),

          const Gap(40),

          // ── Step 2: Property Type ──────────────────────────────────
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '2',
                  style: AppTextStyles.labelSm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Gap(12),
              Text(
                'What are you looking for?',
                style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Gap(16),

          PropertyTypeSelector(
            selectedTypes: _selectedTypes,
            onChanged: (updatedTypes) {
              setState(() {
                _selectedTypes.clear();
                _selectedTypes.addAll(updatedTypes);
              });
            },
          ),
        ],
      ),
    );
  }
}
