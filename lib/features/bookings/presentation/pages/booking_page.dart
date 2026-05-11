import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../properties/presentation/providers/properties_provider.dart';
import '../../domain/entities/booking_entities.dart';
import '../providers/booking_provider.dart';

// ── Page ──────────────────────────────────────────────────────────────────────

class BookingPage extends ConsumerStatefulWidget {
  const BookingPage({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
    this.hostelRoomId,
    this.roomNumber,
  });

  final String propertyId;
  final String propertyTitle;
  final String? hostelRoomId;
  final String? roomNumber;

  @override
  ConsumerState<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends ConsumerState<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _moveInDate;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _moveInDate = picked);
  }

  void _submit() {
    if (ref.read(bookingProvider).isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_moveInDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a move-in date'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    final user = ref.read(authProvider).user;
    ref
        .read(bookingProvider.notifier)
        .submitBooking(
          request: BookingRequest(
            renterName: _nameController.text.trim(),
            renterPhone: _phoneController.text.trim(),
            renterEmail: _emailController.text.trim(),
            propertyId: widget.propertyId,
            hostelRoomId: widget.hostelRoomId,
            moveInDate: _moveInDate!,
            notes: _notesController.text.trim(),
            userId: user?.id,
          ),
          propertyTitle: widget.propertyTitle,
          roomNumber: widget.roomNumber,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingProvider);

    if (state.successResponse != null) {
      return _BookingSuccess(
        propertyTitle: widget.propertyTitle,
        roomNumber: widget.roomNumber,
        cancellationToken: state.successResponse!.cancellationToken,
        onDone: () {
          ref.read(propertiesProvider.notifier).refresh();
          context.go('/browse');
        },
      );
    }

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
          widget.roomNumber != null
              ? 'Book Room ${widget.roomNumber}'
              : 'Request to Book',
          style: AppTextStyles.h4,
        ),
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
            _PropertySummaryCard(
              title: widget.propertyTitle,
              roomNumber: widget.roomNumber,
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),

            const Gap(20),

            if (state.error != null) ...[
              _ErrorBanner(
                message: state.error!,
              ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.05, end: 0),
              const Gap(16),
            ],

            // ── Section 01: Your Details ──────────────────────────────────
            _FormSection(
                  number: '01',
                  title: 'Your Details',
                  icon: Icons.person_outline_rounded,
                  children: [
                    _BookingTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'John Doe',
                      icon: Icons.badge_outlined,
                      enabled: !state.isLoading,
                      capitalization: TextCapitalization.words,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Name is required'
                          : null,
                    ),
                    const Gap(16),
                    _BookingTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: '+256 700 000 000',
                      icon: Icons.phone_outlined,
                      enabled: !state.isLoading,
                      inputType: TextInputType.phone,
                      validator: (v) => v == null || v.trim().length < 10
                          ? 'Enter a valid phone number'
                          : null,
                    ),
                    const Gap(16),
                    _BookingTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'you@example.com',
                      icon: Icons.email_outlined,
                      enabled: !state.isLoading,
                      inputType: TextInputType.emailAddress,
                      isRequired: false,
                    ),
                  ],
                )
                .animate(delay: 60.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.05, end: 0),

            const Gap(16),

            // ── Section 02: Booking Details ───────────────────────────────
            _FormSection(
                  number: '02',
                  title: 'Booking Details',
                  icon: Icons.calendar_month_outlined,
                  children: [
                    _DatePickerField(
                      selectedDate: _moveInDate,
                      enabled: !state.isLoading,
                      onTap: _selectDate,
                    ),
                    const Gap(16),
                    _BookingTextField(
                      controller: _notesController,
                      label: 'Notes / Questions',
                      hint: 'Any special requests or questions for the agent?',
                      icon: Icons.notes_rounded,
                      enabled: !state.isLoading,
                      maxLines: 3,
                      isRequired: false,
                    ),
                  ],
                )
                .animate(delay: 120.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.05, end: 0),

            const Gap(16),

            _InfoCard(
              icon: Icons.info_outline_rounded,
              message:
                  'Your request will be reviewed by the property contact. '
                  'You\'ll receive a cancellation token to manage this booking.',
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

// ── Property Summary Card ─────────────────────────────────────────────────────

class _PropertySummaryCard extends StatelessWidget {
  const _PropertySummaryCard({required this.title, this.roomNumber});

  final String title;
  final String? roomNumber;

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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.home_work_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking Request For',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
                const Gap(3),
                Text(
                  title,
                  style: AppTextStyles.h4,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (roomNumber != null) ...[
                  const Gap(4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.door_back_door_outlined,
                        size: 13,
                        color: AppColors.accent,
                      ),
                      const Gap(4),
                      Text(
                        'Room $roomNumber',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Form Section ──────────────────────────────────────────────────────────────

class _FormSection extends StatelessWidget {
  const _FormSection({
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Booking Text Field ────────────────────────────────────────────────────────

class _BookingTextField extends StatelessWidget {
  const _BookingTextField({
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
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTextStyles.labelMd.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: AppTextStyles.labelMd.copyWith(color: AppColors.error),
              ),
          ],
        ),
        const Gap(7),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: inputType,
          maxLines: maxLines,
          textCapitalization: capitalization,
          style: AppTextStyles.bodyMd,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Icon(icon, size: 18, color: AppColors.grey500),
            ),
            prefixIconConstraints: const BoxConstraints(),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

// ── Date Picker Field ─────────────────────────────────────────────────────────

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.selectedDate,
    required this.enabled,
    required this.onTap,
  });

  final DateTime? selectedDate;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasDate = selectedDate != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Move-in Date',
              style: AppTextStyles.labelMd.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              ' *',
              style: AppTextStyles.labelMd.copyWith(color: AppColors.error),
            ),
          ],
        ),
        const Gap(7),
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: hasDate ? AppColors.primary50 : AppColors.grey50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasDate
                    ? AppColors.primary.withOpacity(0.4)
                    : AppColors.grey300,
                width: hasDate ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 18,
                  color: hasDate ? AppColors.primary : AppColors.grey500,
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    hasDate
                        ? DateFormat('EEEE, MMMM d, yyyy').format(selectedDate!)
                        : 'Select a move-in date',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: hasDate
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                      fontWeight: hasDate ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
                if (hasDate)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Change',
                      style: AppTextStyles.labelSm.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  )
                else
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.grey400,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Error Banner ──────────────────────────────────────────────────────────────

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

// ── Info Card ─────────────────────────────────────────────────────────────────

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

// ── Submit Bar ────────────────────────────────────────────────────────────────

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
                    Text('Submit Booking Request'),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Booking Success Screen ────────────────────────────────────────────────────

class _BookingSuccess extends StatelessWidget {
  const _BookingSuccess({
    required this.propertyTitle,
    required this.cancellationToken,
    required this.onDone,
    this.roomNumber,
  });

  final String propertyTitle;
  final String? roomNumber;
  final String cancellationToken;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Gap(32),

              // ── Animated success icon ────────────────────────────────────
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

              const Gap(24),

              Text(
                    'Request Submitted!',
                    style: AppTextStyles.h1,
                    textAlign: TextAlign.center,
                  )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.1, end: 0),

              const Gap(10),

              Text(
                'Your booking request for '
                '${roomNumber != null ? 'Room $roomNumber at ' : ''}'
                '$propertyTitle has been sent.',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 260.ms).fadeIn(duration: 300.ms),

              const Gap(32),

              // ── Token card ───────────────────────────────────────────────
              Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withOpacity(0.08),
                          AppColors.accent.withOpacity(0.06),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.key_rounded,
                              size: 17,
                              color: AppColors.primary,
                            ),
                            const Gap(8),
                            Text(
                              'Your Cancellation Token',
                              style: AppTextStyles.labelLg.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const Gap(16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            cancellationToken,
                            style: AppTextStyles.h1.copyWith(
                              color: AppColors.primary,
                              letterSpacing: 10,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Gap(14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                size: 15,
                                color: AppColors.accent,
                              ),
                              const Gap(8),
                              Expanded(
                                child: Text(
                                  'Save this token — you\'ll need it to cancel this booking. '
                                  'It has also been saved to your "My Bookings" tab.',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.accent,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate(delay: 360.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.06, end: 0),

              const Gap(20),

              // ── What's next ──────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("What's next?", style: AppTextStyles.labelLg),
                    const Gap(12),
                    ..._nextSteps.map(
                      (step) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.primary50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                step.$2,
                                size: 15,
                                color: AppColors.primary,
                              ),
                            ),
                            const Gap(10),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  step.$1,
                                  style: AppTextStyles.bodySm.copyWith(
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 460.ms).fadeIn(duration: 400.ms),

              const Gap(28),

              ElevatedButton.icon(
                onPressed: onDone,
                icon: const Icon(Icons.explore_rounded, size: 18),
                label: const Text('Back to Explore'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
              ).animate(delay: 540.ms).fadeIn(duration: 300.ms),

              const Gap(8),
            ],
          ),
        ),
      ),
    );
  }

  static const _nextSteps = [
    ('The property contact will review your request.', Icons.pending_outlined),
    (
      'You\'ll be contacted via the phone number you provided.',
      Icons.phone_callback_outlined,
    ),
    (
      'Check "My Bookings" to track your requests and cancel if needed.',
      Icons.receipt_long_outlined,
    ),
  ];
}
