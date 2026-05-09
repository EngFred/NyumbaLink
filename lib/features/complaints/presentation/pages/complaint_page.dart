import 'package:flutter/material.dart';
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
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();

  late String _selectedCategory;

  static const _categories = {
    'PROPERTY_CONDITION': 'Property Condition / Maintenance',
    'CONTACT_CONDUCT': 'Agent / Owner Conduct',
    'PRICING': 'Pricing Issue / Hidden Charges',
    'BOOKING': 'Booking Issue',
    'APP_ISSUE': 'App Bug / Technical Issue',
    'GENERAL': 'General Feedback',
    'OTHER': 'Other',
  };

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.propertyId != null
        ? 'PROPERTY_CONDITION'
        : 'APP_ISSUE';

    // Auto-fill user details if logged in
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
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (ref.read(complaintProvider).isLoading) return;

    if (_formKey.currentState?.validate() ?? false) {
      final user = ref.read(authProvider).user; // <-- Fetch user

      final request = ComplaintRequest(
        submitterName: _nameController.text.trim(),
        submitterPhone: _phoneController.text.trim(),
        submitterEmail: _emailController.text.trim(),
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        propertyId: widget.propertyId,
        userId: user?.id, // <-- ADDED: Attach userId to the request
      );

      ref.read(complaintProvider.notifier).submit(request);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(complaintProvider);

    if (state.isSuccess) {
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
                Text('Feedback Submitted', style: AppTextStyles.h1),
                const Gap(16),
                Text(
                  'Thank you for bringing this to our attention. Our administrative team will review it shortly.',
                  style: AppTextStyles.bodyMd,
                  textAlign: TextAlign.center,
                ),
                const Gap(40),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Report an Issue')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.propertyTitle != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.home_work_outlined,
                          color: AppColors.primary,
                        ),
                        const Gap(12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reporting Property',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                widget.propertyTitle!,
                                style: AppTextStyles.h4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(32),
                ] else ...[
                  Text('How can we help?', style: AppTextStyles.h2),
                  const Gap(8),
                  Text(
                    'Let us know about an issue with the app or our service.',
                    style: AppTextStyles.bodySm,
                  ),
                  const Gap(32),
                ],

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

                Text('Category *', style: AppTextStyles.labelLg),
                const Gap(8),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: _categories.entries.map((e) {
                    return DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value, style: AppTextStyles.bodyMd),
                    );
                  }).toList(),
                  onChanged: state.isLoading
                      ? null
                      : (v) {
                          if (v != null) setState(() => _selectedCategory = v);
                        },
                ),
                const Gap(20),

                Text('Your Name *', style: AppTextStyles.labelLg),
                const Gap(8),
                TextFormField(
                  controller: _nameController,
                  enabled: !state.isLoading,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'John Doe',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => v == null || v.trim().length < 2
                      ? 'Name must be at least 2 characters'
                      : null,
                ),
                const Gap(20),

                Text('Phone Number *', style: AppTextStyles.labelLg),
                const Gap(8),
                TextFormField(
                  controller: _phoneController,
                  enabled: !state.isLoading,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: '+256 700 000000',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Phone number is required'
                      : null,
                ),
                const Gap(20),

                Text('Email Address (Optional)', style: AppTextStyles.labelLg),
                const Gap(8),
                TextFormField(
                  controller: _emailController,
                  enabled: !state.isLoading,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'you@example.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const Gap(20),

                Text('Description *', style: AppTextStyles.labelLg),
                const Gap(8),
                TextFormField(
                  controller: _descriptionController,
                  enabled: !state.isLoading,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Please provide as much detail as possible...',
                  ),
                  validator: (v) => v == null || v.trim().length < 10
                      ? 'Description must be at least 10 characters'
                      : null,
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
                      : const Text('Submit Feedback'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
