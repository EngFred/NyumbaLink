import 'package:flutter/material.dart';
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

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _moveInDate = picked);
    }
  }

  void _submit() {
    if (ref.read(bookingProvider).isLoading) return;

    if (_formKey.currentState?.validate() ?? false) {
      if (_moveInDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a move-in date')),
        );
        return;
      }

      final request = BookingRequest(
        renterName: _nameController.text.trim(),
        renterPhone: _phoneController.text.trim(),
        renterEmail: _emailController.text.trim(),
        propertyId: widget.propertyId,
        hostelRoomId: widget.hostelRoomId,
        moveInDate: _moveInDate!,
        notes: _notesController.text.trim(),
      );

      ref
          .read(bookingProvider.notifier)
          .submitBooking(
            request: request,
            propertyTitle: widget.propertyTitle,
            roomNumber: widget.roomNumber,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingProvider);

    if (state.successResponse != null) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 80,
                  color: AppColors.success,
                ),
                const Gap(24),
                Text('Request Submitted!', style: AppTextStyles.h1),
                const Gap(16),
                Text(
                  'Your booking request for ${widget.roomNumber != null ? 'Room ${widget.roomNumber} at ' : ''}${widget.propertyTitle} has been sent.',
                  style: AppTextStyles.bodyMd,
                  textAlign: TextAlign.center,
                ),
                const Gap(32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary100),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Your Cancellation Token',
                        style: AppTextStyles.labelMd,
                      ),
                      const Gap(8),
                      Text(
                        state.successResponse!.cancellationToken,
                        style: AppTextStyles.displayLg.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 8,
                        ),
                      ),
                      const Gap(12),
                      Text(
                        'Keep this safe! You will need it if you want to cancel. We have also saved it to your "My Bookings" tab locally.',
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const Gap(40),
                ElevatedButton(
                  onPressed: () {
                    ref.read(propertiesProvider.notifier).refresh();
                    context.go('/browse');
                  },
                  child: const Text('Back to Explore'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.roomNumber != null
              ? 'Book Room ${widget.roomNumber}'
              : 'Request to Book',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.propertyTitle, style: AppTextStyles.h2),
                const Gap(8),
                Text(
                  'Provide your details below to secure this property.',
                  style: AppTextStyles.bodySm,
                ),
                const Gap(32),

                if (state.error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error),
                        const Gap(8),
                        Expanded(
                          child: Text(
                            state.error!,
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(24),
                ],

                Text('Full Name *', style: AppTextStyles.labelLg),
                const Gap(8),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  enabled: !state.isLoading,
                  decoration: const InputDecoration(
                    hintText: 'John Doe',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                const Gap(20),

                Text('Phone Number *', style: AppTextStyles.labelLg),
                const Gap(8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  enabled: !state.isLoading,
                  decoration: const InputDecoration(
                    hintText: '+256 700 000000',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (v) => v == null || v.trim().length < 10
                      ? 'Enter a valid phone number'
                      : null,
                ),
                const Gap(20),

                Text('Email Address (Optional)', style: AppTextStyles.labelLg),
                const Gap(8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !state.isLoading,
                  decoration: const InputDecoration(
                    hintText: 'you@example.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const Gap(20),

                Text('Move-in Date *', style: AppTextStyles.labelLg),
                const Gap(8),
                InkWell(
                  onTap: state.isLoading ? null : () => _selectDate(context),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: state.isLoading
                          ? AppColors.grey100
                          : AppColors.grey50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.grey300),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                          color: AppColors.grey500,
                        ),
                        const Gap(12),
                        Text(
                          _moveInDate == null
                              ? 'Select Date'
                              : DateFormat('MMM dd, yyyy').format(_moveInDate!),
                          style: AppTextStyles.bodyMd.copyWith(
                            color: _moveInDate == null
                                ? AppColors.textHint
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(20),

                Text(
                  'Notes / Questions (Optional)',
                  style: AppTextStyles.labelLg,
                ),
                const Gap(8),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  enabled: !state.isLoading,
                  decoration: const InputDecoration(
                    hintText:
                        'Any special requests or questions for the agent?',
                  ),
                ),
                const Gap(40),

                ElevatedButton(
                  onPressed: state.isLoading ? null : _submit,
                  child: state.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Submit Request'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
