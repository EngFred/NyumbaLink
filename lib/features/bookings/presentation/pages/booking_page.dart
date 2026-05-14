import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:rentora/features/account/presentation/widgets/edit-profile/form_section.dart';
import 'package:rentora/features/bookings/presentation/widgets/book/booking_success.dart';
import 'package:rentora/features/bookings/presentation/widgets/book/booking_text_field.dart';
import 'package:rentora/features/bookings/presentation/widgets/book/date_picker_field.dart';
import 'package:rentora/features/bookings/presentation/widgets/book/error_banner.dart';
import 'package:rentora/features/bookings/presentation/widgets/book/info_card.dart';
import 'package:rentora/features/bookings/presentation/widgets/book/property_summary_card.dart';
import 'package:rentora/features/bookings/presentation/widgets/book/submit_bar.dart';

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
      return BookingSuccess(
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
            PropertySummaryCard(
              title: widget.propertyTitle,
              roomNumber: widget.roomNumber,
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),

            const Gap(20),

            if (state.error != null) ...[
              ErrorBanner(
                message: state.error!,
              ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.05, end: 0),
              const Gap(16),
            ],

            // ── Section 01: Your Details ──────────────────────────────────
            FormSection(
                  number: '01',
                  title: 'Your Details',
                  icon: Icons.person_outline_rounded,
                  children: [
                    BookingTextField(
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
                    BookingTextField(
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
                    BookingTextField(
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
            FormSection(
                  number: '02',
                  title: 'Booking Details',
                  icon: Icons.calendar_month_outlined,
                  children: [
                    DatePickerField(
                      selectedDate: _moveInDate,
                      enabled: !state.isLoading,
                      onTap: _selectDate,
                    ),
                    const Gap(16),
                    BookingTextField(
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

            const InfoCard(
              icon: Icons.info_outline_rounded,
              message:
                  'Your request will be reviewed by the property contact. '
                  'You\'ll receive a cancellation token to manage this booking.',
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
