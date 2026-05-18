import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:rentora/features/complaints/presentation/widgets/category_grid.dart';
import 'package:rentora/features/complaints/presentation/widgets/complaint_field.dart';
import 'package:rentora/features/complaints/presentation/widgets/confirm_report_sheet.dart';
import 'package:rentora/features/complaints/presentation/widgets/intro_header.dart';
import 'package:rentora/features/complaints/presentation/widgets/property_context.dart';
import 'package:rentora/features/complaints/presentation/widgets/success_view.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_info_card.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_submit_bar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/complaint_entities.dart';
import '../providers/complaint_provider.dart';

class ComplaintPage extends ConsumerStatefulWidget {
  const ComplaintPage({super.key, this.propertyId, this.propertyTitle});
  final String? propertyId;
  final String? propertyTitle;

  @override
  ConsumerState<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends ConsumerState<ComplaintPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  late String _category;

  bool _nameIsPrefilled = false;
  bool _emailIsPrefilled = false;

  @override
  void initState() {
    super.initState();
    _category = widget.propertyId != null ? 'PROPERTY_CONDITION' : 'APP_ISSUE';

    final user = ref.read(authProvider).user;
    if (user != null) {
      _nameCtrl.text = user.name;
      _emailCtrl.text = user.email;
      _nameIsPrefilled = user.name.isNotEmpty;
      _emailIsPrefilled = user.email.isNotEmpty;
    }
    _nameCtrl.addListener(_onNameChanged);
    _emailCtrl.addListener(_onEmailChanged);
  }

  void _onNameChanged() {
    if (_nameIsPrefilled) setState(() => _nameIsPrefilled = false);
  }

  void _onEmailChanged() {
    if (_emailIsPrefilled) setState(() => _emailIsPrefilled = false);
  }

  @override
  void dispose() {
    _nameCtrl.removeListener(_onNameChanged);
    _emailCtrl.removeListener(_onEmailChanged);
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmitTap() async {
    if (ref.read(complaintProvider).isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent, // Ensures our custom rounded sheet works
      builder: (_) => ConfirmReportSheet(
        category: _category,
        name: _nameCtrl.text.trim(),
        phone: '+256 ${_phoneCtrl.text.trim()}',
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        propertyTitle: widget.propertyTitle,
      ),
    );

    if (confirmed == true) _submitReport();
  }

  void _submitReport() {
    final user = ref.read(authProvider).user;
    ref
        .read(complaintProvider.notifier)
        .submit(
          ComplaintRequest(
            submitterName: _nameCtrl.text.trim(),
            submitterPhone: '+256${_phoneCtrl.text.trim()}',
            submitterEmail: _emailCtrl.text.trim(),
            category: _category,
            description: _descCtrl.text.trim(),
            propertyId: widget.propertyId,
            userId: user?.id,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ComplaintState>(complaintProvider, (prev, next) {
      if (next.error != null && prev?.error != next.error) {
        AppSnackbar.error(context, next.error!);
      }
    });

    final state = ref.watch(complaintProvider);

    if (state.isSuccess) return SuccessView(onDone: () => context.pop());

    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.surface, // Completely flat background
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Report an Issue',
          style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 100 + bottomPad),
          children: [
            // ── Context header (Unboxed) ──────────────────────────────────
            if (widget.propertyTitle != null)
              PropertyContext(
                title: widget.propertyTitle!,
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0)
            else
              const IntroHeader()
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.05, end: 0),

            const Gap(32),

            // Required fields legend
            Row(
              children: [
                Text(
                  '* ',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Required fields',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 200.ms),

            const Gap(16),

            // ── Section 01: Category (Unboxed) ───────────────────────────
            const _SectionHeader(
              number: '01',
              title: 'Issue Category',
            ).animate(delay: 60.ms).fadeIn(duration: 300.ms),

            const Gap(16),
            CategoryGrid(
              selected: _category,
              onSelect: (c) => setState(() => _category = c),
              isEnabled: !state.isLoading,
            ).animate(delay: 60.ms).fadeIn(duration: 300.ms),

            const Gap(32),
            const Divider(height: 1, color: AppColors.grey100),
            const Gap(32),

            // ── Section 02: Your Details (Unboxed) ───────────────────────
            const _SectionHeader(
              number: '02',
              title: 'Your Details',
            ).animate(delay: 100.ms).fadeIn(duration: 300.ms),

            const Gap(16),
            ComplaintField(
              controller: _nameCtrl,
              label: 'Full Name',
              hint: 'Your full name',
              icon: Icons.badge_outlined,
              enabled: !state.isLoading,
              capitalization: TextCapitalization.words,
              isPrefilled: _nameIsPrefilled,
              validator: (v) => (v?.trim().length ?? 0) < 2
                  ? 'Name must be at least 2 characters'
                  : null,
            ).animate(delay: 100.ms).fadeIn(duration: 300.ms),

            const Gap(16),
            ComplaintField(
              controller: _phoneCtrl,
              label: 'Phone Number',
              hint: '700 000 000',
              icon: Icons.phone_outlined,
              enabled: !state.isLoading,
              inputType: TextInputType.phone,
              phonePrefix: '+256',
              maxLength: 9,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Phone number is required';
                }
                final digits = v.trim().replaceAll(RegExp(r'\D'), '');
                if (digits.length < 9) {
                  return 'Enter 9 digits after +256';
                }
                return null;
              },
            ).animate(delay: 120.ms).fadeIn(duration: 300.ms),

            const Gap(16),
            ComplaintField(
              controller: _emailCtrl,
              label: 'Email Address',
              hint: 'you@example.com',
              icon: Icons.email_outlined,
              enabled: !state.isLoading,
              inputType: TextInputType.emailAddress,
              isPrefilled: _emailIsPrefilled,
              isRequired: false,
            ).animate(delay: 140.ms).fadeIn(duration: 300.ms),

            const Gap(32),
            const Divider(height: 1, color: AppColors.grey100),
            const Gap(32),

            // ── Section 03: Description (Unboxed) ────────────────────────
            const _SectionHeader(
              number: '03',
              title: 'Description',
            ).animate(delay: 160.ms).fadeIn(duration: 300.ms),

            const Gap(16),
            ComplaintField(
              controller: _descCtrl,
              label: 'Describe the issue',
              hint:
                  'Please provide as much detail as possible so we can help you effectively...',
              icon: Icons.edit_note_rounded,
              enabled: !state.isLoading,
              maxLines: 5,
              maxLength: 600,
              validator: (v) => (v?.trim().length ?? 0) < 10
                  ? 'Please provide at least 10 characters'
                  : null,
            ).animate(delay: 180.ms).fadeIn(duration: 300.ms),

            const Gap(32),
            const AppInfoCard(
              icon: Icons.info_outline_rounded,
              message:
                  'Our administrative team reviews all reports within 24–48 hours. '
                  'We take every concern seriously.',
            ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
          ],
        ),
      ),
      bottomNavigationBar: AppSubmitBar(
        label: 'Review & Submit',
        icon: Icons.arrow_forward_rounded,
        isLoading: state.isLoading,
        onSubmit: _onSubmitTap,
      ),
    );
  }
}

// Same clean section header as your Booking flow
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.number, required this.title});
  final String number;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: AppTextStyles.labelSm.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Gap(12),
        Text(
          title,
          style: AppTextStyles.h4.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
