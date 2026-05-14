import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:rentora/features/bookings/presentation/widgets/book/error_banner.dart';
import 'package:rentora/features/bookings/presentation/widgets/book/info_card.dart';
import 'package:rentora/features/complaints/presentation/widgets/category_grid.dart';
import 'package:rentora/features/complaints/presentation/widgets/complaint_field.dart';
import 'package:rentora/features/complaints/presentation/widgets/complaint_section.dart';
import 'package:rentora/features/complaints/presentation/widgets/intro_header.dart';
import 'package:rentora/features/complaints/presentation/widgets/property_context.dart';
import 'package:rentora/features/complaints/presentation/widgets/submit_bar.dart';
import 'package:rentora/features/complaints/presentation/widgets/success_view.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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

  // static const _categories = {
  //   'PROPERTY_CONDITION': 'Property Condition',
  //   'CONTACT_CONDUCT': 'Agent / Owner Conduct',
  //   'PRICING': 'Pricing / Hidden Charges',
  //   'BOOKING': 'Booking Issue',
  //   'APP_ISSUE': 'App Bug / Technical Issue',
  //   'GENERAL': 'General Feedback',
  //   'OTHER': 'Other',
  // };

  // static const _categoryIcons = {
  //   'PROPERTY_CONDITION': Icons.home_repair_service_outlined,
  //   'CONTACT_CONDUCT': Icons.person_off_outlined,
  //   'PRICING': Icons.price_change_outlined,
  //   'BOOKING': Icons.receipt_long_outlined,
  //   'APP_ISSUE': Icons.bug_report_outlined,
  //   'GENERAL': Icons.feedback_outlined,
  //   'OTHER': Icons.more_horiz_rounded,
  // };

  @override
  void initState() {
    super.initState();
    _category = widget.propertyId != null ? 'PROPERTY_CONDITION' : 'APP_ISSUE';
    final user = ref.read(authProvider).user;
    if (user != null) {
      _nameCtrl.text = user.name;
      _emailCtrl.text = user.email;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (ref.read(complaintProvider).isLoading) return;
    if (_formKey.currentState?.validate() ?? false) {
      final user = ref.read(authProvider).user;
      ref
          .read(complaintProvider.notifier)
          .submit(
            ComplaintRequest(
              submitterName: _nameCtrl.text.trim(),
              submitterPhone: _phoneCtrl.text.trim(),
              submitterEmail: _emailCtrl.text.trim(),
              category: _category,
              description: _descCtrl.text.trim(),
              propertyId: widget.propertyId,
              userId: user?.id,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(complaintProvider);

    if (state.isSuccess) return SuccessView(onDone: () => context.pop());

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
        title: Text('Report an Issue', style: AppTextStyles.h4),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.grey200),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            // ── Property context card ────────────────────────────────────
            if (widget.propertyTitle != null)
              PropertyContext(
                title: widget.propertyTitle!,
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),

            if (widget.propertyTitle == null) ...[
              const IntroHeader()
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.05, end: 0),
            ],

            if (state.error != null) ...[
              const Gap(12),
              ErrorBanner(
                message: state.error!,
              ).animate().fadeIn(duration: 200.ms),
            ],

            const Gap(16),

            // ── Section 01: Category ─────────────────────────────────────
            ComplaintSection(
                  number: '01',
                  title: 'Issue Category',
                  icon: Icons.category_outlined,
                  children: [
                    CategoryGrid(
                      selected: _category,
                      onSelect: (c) => setState(() => _category = c),
                      isEnabled: !state.isLoading,
                    ),
                  ],
                )
                .animate(delay: 60.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.04, end: 0),

            const Gap(16),

            // ── Section 02: Your details ─────────────────────────────────
            ComplaintSection(
                  number: '02',
                  title: 'Your Details',
                  icon: Icons.person_outline_rounded,
                  children: [
                    ComplaintField(
                      controller: _nameCtrl,
                      label: 'Full Name',
                      hint: 'John Doe',
                      icon: Icons.badge_outlined,
                      enabled: !state.isLoading,
                      capitalization: TextCapitalization.words,
                      validator: (v) => (v?.trim().length ?? 0) < 2
                          ? 'Name must be at least 2 characters'
                          : null,
                    ),
                    const _Divider(),
                    ComplaintField(
                      controller: _phoneCtrl,
                      label: 'Phone Number',
                      hint: '+256 700 000 000',
                      icon: Icons.phone_outlined,
                      enabled: !state.isLoading,
                      inputType: TextInputType.phone,
                      validator: (v) => (v?.trim().isEmpty ?? true)
                          ? 'Phone number is required'
                          : null,
                    ),
                    const _Divider(),
                    ComplaintField(
                      controller: _emailCtrl,
                      label: 'Email (optional)',
                      hint: 'you@example.com',
                      icon: Icons.email_outlined,
                      enabled: !state.isLoading,
                      inputType: TextInputType.emailAddress,
                      isRequired: false,
                    ),
                  ],
                )
                .animate(delay: 100.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.04, end: 0),

            const Gap(16),

            // ── Section 03: Description ──────────────────────────────────
            ComplaintSection(
                  number: '03',
                  title: 'Description',
                  icon: Icons.notes_rounded,
                  children: [
                    ComplaintField(
                      controller: _descCtrl,
                      label: 'Describe the issue',
                      hint:
                          'Please provide as much detail as possible so we can help you effectively...',
                      icon: Icons.edit_note_rounded,
                      enabled: !state.isLoading,
                      maxLines: 5,
                      validator: (v) => (v?.trim().length ?? 0) < 10
                          ? 'Please provide at least 10 characters'
                          : null,
                    ),
                  ],
                )
                .animate(delay: 140.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.04, end: 0),

            const Gap(16),

            const InfoCard(
              icon: Icons.info_outline_rounded,
              message:
                  'Our administrative team reviews all reports within 24–48 hours. We take every concern seriously.',
            ).animate(delay: 180.ms).fadeIn(duration: 300.ms),
          ],
        ),
      ),
      bottomNavigationBar: SubmitBar(
        isLoading: state.isLoading,
        onSubmit: _submit,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Divider(
    height: 1,
    color: AppColors.grey100,
    indent: 16,
    endIndent: 16,
  );
}
