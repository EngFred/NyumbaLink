import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:rentora/features/bookings/presentation/widgets/book/booking_success.dart';
import 'package:rentora/features/bookings/presentation/widgets/book/booking_text_field.dart';
import 'package:rentora/features/bookings/presentation/widgets/book/confirm_booking_sheet.dart';
import 'package:rentora/features/bookings/presentation/widgets/book/date_picker_field.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_info_card.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_submit_bar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../properties/presentation/providers/properties_provider.dart';
import '../../domain/entities/booking_entities.dart';
import '../providers/booking_provider.dart';

class BookingPage extends ConsumerStatefulWidget {
  const BookingPage({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
    required this.price,
    required this.location,
    this.imageUrl,
    this.hostelRoomId,
    this.roomNumber,
  });

  final String propertyId;
  final String propertyTitle;
  final double price;
  final String location;
  final String? imageUrl;
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

  bool _nameIsPrefilled = false;
  bool _emailIsPrefilled = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _nameIsPrefilled = user.name.isNotEmpty;
      _emailIsPrefilled = user.email.isNotEmpty;
    }
    _nameController.addListener(_onNameChanged);
    _emailController.addListener(_onEmailChanged);
  }

  void _onNameChanged() {
    if (_nameIsPrefilled) setState(() => _nameIsPrefilled = false);
  }

  void _onEmailChanged() {
    if (_emailIsPrefilled) setState(() => _emailIsPrefilled = false);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _emailController.removeListener(_onEmailChanged);
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
      helpText: 'SELECT MOVE-IN DATE',
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

  Future<void> _onSubmitTap() async {
    if (ref.read(bookingProvider).isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_moveInDate == null) {
      AppSnackbar.error(context, 'Please select a move-in date');
      return;
    }

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ConfirmBookingSheet(
        propertyTitle: widget.propertyTitle,
        roomNumber: widget.roomNumber,
        name: _nameController.text.trim(),
        phone: '+256 ${_phoneController.text.trim()}',
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        moveInDate: _moveInDate!,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      ),
    );

    if (confirmed == true) _submitBooking();
  }

  void _submitBooking() {
    final user = ref.read(authProvider).user;
    ref
        .read(bookingProvider.notifier)
        .submitBooking(
          request: BookingRequest(
            renterName: _nameController.text.trim(),
            renterPhone: '+256${_phoneController.text.trim()}',
            renterEmail: _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
            propertyId: widget.propertyId,
            hostelRoomId: widget.hostelRoomId,
            moveInDate: _moveInDate!,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
            userId: user?.id,
          ),
          propertyTitle: widget.propertyTitle,
          price: widget.price, // NEW FIX
          location: widget.location, // NEW FIX
          thumbnailUrl: widget.imageUrl, // NEW FIX
          roomNumber: widget.roomNumber,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<BookingState>(bookingProvider, (prev, next) {
      if (next.error != null && prev?.error != next.error) {
        AppSnackbar.error(context, next.error!);
      }
    });

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

    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.surface,
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
          widget.roomNumber != null ? 'Book Room' : 'Request to Book',
          style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 100 + bottomPad),
          children: [
            // Using the _RichPropertySummary widget we defined in the previous step
            _RichPropertySummary(
              title: widget.propertyTitle,
              location: widget.location,
              price: widget.price,
              imageUrl: widget.imageUrl,
              roomNumber: widget.roomNumber,
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),

            const Gap(32),

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

            const _SectionHeader(
              number: '01',
              title: 'Your Details',
            ).animate(delay: 60.ms).fadeIn(duration: 300.ms),
            const Gap(16),
            BookingTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Your full name',
              icon: Icons.badge_outlined,
              enabled: !state.isLoading,
              capitalization: TextCapitalization.words,
              isPrefilled: _nameIsPrefilled,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ).animate(delay: 60.ms).fadeIn(duration: 300.ms),
            const Gap(16),
            BookingTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: '700 000 000',
              icon: Icons.phone_outlined,
              enabled: !state.isLoading,
              inputType: TextInputType.phone,
              phonePrefix: '+256',
              maxLength: 9,
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return 'Phone number is required';
                final digits = v.trim().replaceAll(RegExp(r'\D'), '');
                if (digits.length < 9) return 'Enter 9 digits after +256';
                return null;
              },
            ).animate(delay: 80.ms).fadeIn(duration: 300.ms),
            const Gap(16),
            BookingTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'you@example.com',
              icon: Icons.email_outlined,
              enabled: !state.isLoading,
              inputType: TextInputType.emailAddress,
              isPrefilled: _emailIsPrefilled,
              isRequired: false,
            ).animate(delay: 100.ms).fadeIn(duration: 300.ms),

            const Gap(32),
            const Divider(height: 1, color: AppColors.grey100),
            const Gap(32),

            const _SectionHeader(
              number: '02',
              title: 'Booking Details',
            ).animate(delay: 120.ms).fadeIn(duration: 300.ms),
            const Gap(16),
            DatePickerField(
              selectedDate: _moveInDate,
              enabled: !state.isLoading,
              onTap: _selectDate,
              onClear: () => setState(() => _moveInDate = null),
            ).animate(delay: 140.ms).fadeIn(duration: 300.ms),
            const Gap(16),
            BookingTextField(
              controller: _notesController,
              label: 'Notes / Questions',
              hint: 'Any special requests or questions for the agent?',
              icon: Icons.notes_rounded,
              enabled: !state.isLoading,
              maxLines: 3,
              maxLength: 300,
              isRequired: false,
            ).animate(delay: 160.ms).fadeIn(duration: 300.ms),

            const Gap(32),

            const AppInfoCard(
              icon: Icons.info_outline_rounded,
              message:
                  'Your request will be reviewed by the property contact. You\'ll receive a cancellation token to manage this booking.',
            ).animate(delay: 180.ms).fadeIn(duration: 300.ms),
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

class _RichPropertySummary extends StatelessWidget {
  const _RichPropertySummary({
    required this.title,
    required this.location,
    required this.price,
    this.imageUrl,
    this.roomNumber,
  });

  final String title;
  final String location;
  final double price;
  final String? imageUrl;
  final String? roomNumber;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'UGX ',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.grey200 ?? Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.hardEdge,
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(imageUrl!, fit: BoxFit.cover)
                : const Center(
                    child: Icon(
                      Icons.home_work_outlined,
                      color: AppColors.grey400,
                    ),
                  ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (roomNumber != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Room $roomNumber',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Gap(6),
                ],
                Text(
                  title,
                  style: AppTextStyles.labelLg.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const Gap(4),
                    Expanded(
                      child: Text(
                        location.isNotEmpty ? location : 'Location unavailable',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (price > 0) ...[
                  const Gap(8),
                  Text(
                    currencyFormat.format(price),
                    style: AppTextStyles.h4.copyWith(color: AppColors.primary),
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
