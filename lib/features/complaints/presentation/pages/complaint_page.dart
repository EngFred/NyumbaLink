import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

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

  static const _categories = {
    'PROPERTY_CONDITION': 'Property Condition',
    'CONTACT_CONDUCT': 'Agent / Owner Conduct',
    'PRICING': 'Pricing / Hidden Charges',
    'BOOKING': 'Booking Issue',
    'APP_ISSUE': 'App Bug / Technical Issue',
    'GENERAL': 'General Feedback',
    'OTHER': 'Other',
  };

  static const _categoryIcons = {
    'PROPERTY_CONDITION': Icons.home_repair_service_outlined,
    'CONTACT_CONDUCT': Icons.person_off_outlined,
    'PRICING': Icons.price_change_outlined,
    'BOOKING': Icons.receipt_long_outlined,
    'APP_ISSUE': Icons.bug_report_outlined,
    'GENERAL': Icons.feedback_outlined,
    'OTHER': Icons.more_horiz_rounded,
  };

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

    if (state.isSuccess) return _SuccessView(onDone: () => context.pop());

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
              _PropertyContext(
                title: widget.propertyTitle!,
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),

            if (widget.propertyTitle == null) ...[
              _IntroHeader()
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.05, end: 0),
            ],

            if (state.error != null) ...[
              const Gap(12),
              _ErrorBanner(
                message: state.error!,
              ).animate().fadeIn(duration: 200.ms),
            ],

            const Gap(16),

            // ── Section 01: Category ─────────────────────────────────────
            _ComplaintSection(
                  number: '01',
                  title: 'Issue Category',
                  icon: Icons.category_outlined,
                  children: [
                    _CategoryGrid(
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
            _ComplaintSection(
                  number: '02',
                  title: 'Your Details',
                  icon: Icons.person_outline_rounded,
                  children: [
                    _ComplaintField(
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
                    _ComplaintField(
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
                    _ComplaintField(
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
            _ComplaintSection(
                  number: '03',
                  title: 'Description',
                  icon: Icons.notes_rounded,
                  children: [
                    _ComplaintField(
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

            const _InfoCard(
              icon: Icons.info_outline_rounded,
              message:
                  'Our administrative team reviews all reports within 24–48 hours. We take every concern seriously.',
            ).animate(delay: 180.ms).fadeIn(duration: 300.ms),
          ],
        ),
      ),
      bottomNavigationBar: _SubmitBar(
        isLoading: state.isLoading,
        onSubmit: _submit,
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _PropertyContext extends StatelessWidget {
  const _PropertyContext({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.08),
            AppColors.accent.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.flag_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reporting Property',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
                const Gap(2),
                Text(
                  title,
                  style: AppTextStyles.h4,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.support_agent_rounded,
            color: AppColors.primary,
            size: 26,
          ),
        ),
        const Gap(14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('How can we help?', style: AppTextStyles.h3),
              const Gap(3),
              Text(
                'Let us know about any issue with the app or our service.',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 18,
          ),
          const Gap(10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplaintSection extends StatelessWidget {
  const _ComplaintSection({
    required this.number,
    required this.title,
    required this.icon,
    required this.children,
  });

  final String number;
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Gap(10),
                Icon(icon, size: 17, color: AppColors.primary),
                const Gap(6),
                Text(title, style: AppTextStyles.h4),
              ],
            ),
          ),
          const Gap(4),
          const Divider(color: AppColors.grey100, height: 1),
          ...children,
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.selected,
    required this.onSelect,
    required this.isEnabled,
  });

  final String selected;
  final ValueChanged<String> onSelect;
  final bool isEnabled;

  static const _icons = {
    'PROPERTY_CONDITION': Icons.home_repair_service_outlined,
    'CONTACT_CONDUCT': Icons.person_off_outlined,
    'PRICING': Icons.price_change_outlined,
    'BOOKING': Icons.receipt_long_outlined,
    'APP_ISSUE': Icons.bug_report_outlined,
    'GENERAL': Icons.feedback_outlined,
    'OTHER': Icons.more_horiz_rounded,
  };

  static const _labels = {
    'PROPERTY_CONDITION': 'Property Condition',
    'CONTACT_CONDUCT': 'Agent Conduct',
    'PRICING': 'Pricing Issue',
    'BOOKING': 'Booking Issue',
    'APP_ISSUE': 'App Bug',
    'GENERAL': 'General',
    'OTHER': 'Other',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _icons.keys.map((key) {
          final isSel = selected == key;
          return GestureDetector(
            onTap: isEnabled ? () => onSelect(key) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: isSel ? AppColors.primary : AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
                border: isSel ? null : Border.all(color: AppColors.grey200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _icons[key]!,
                    size: 14,
                    color: isSel ? Colors.white : AppColors.grey600,
                  ),
                  const Gap(6),
                  Text(
                    _labels[key]!,
                    style: AppTextStyles.labelSm.copyWith(
                      color: isSel ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
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

class _ComplaintField extends StatelessWidget {
  const _ComplaintField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.enabled,
    this.inputType,
    this.maxLines = 1,
    this.capitalization = TextCapitalization.none,
    this.isRequired = true,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool enabled;
  final TextInputType? inputType;
  final int maxLines;
  final TextCapitalization capitalization;
  final bool isRequired;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: AppColors.primary),
              const Gap(5),
              Text(
                label,
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
              if (isRequired)
                Text(
                  ' *',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.error,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
          TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: inputType,
            maxLines: maxLines,
            textCapitalization: capitalization,
            style: AppTextStyles.bodyMd,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              isDense: true,
            ),
            validator: validator,
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.grey500, size: 16),
          const Gap(10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({required this.isLoading, required this.onSubmit});

  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onSubmit,
          style: ElevatedButton.styleFrom(minimumSize: const Size(0, 52)),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send_rounded, size: 18),
                    Gap(10),
                    Text('Submit Report'),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Success screen ────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.onDone});
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 52,
                      color: AppColors.success,
                    ),
                  )
                  .animate()
                  .scale(
                    begin: const Offset(0.4, 0.4),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 300.ms),

              const Gap(28),

              Text(
                    'Report Submitted!',
                    style: AppTextStyles.h1,
                    textAlign: TextAlign.center,
                  )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.1, end: 0),

              const Gap(12),

              Text(
                'Thank you for bringing this to our attention. Our team will review your report within 24–48 hours.',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 280.ms).fadeIn(duration: 300.ms),

              const Gap(40),

              ElevatedButton.icon(
                onPressed: onDone,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text('Done'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
              ).animate(delay: 380.ms).fadeIn(duration: 300.ms),
            ],
          ),
        ),
      ),
    );
  }
}
