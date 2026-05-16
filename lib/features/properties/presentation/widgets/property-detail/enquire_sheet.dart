import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/contact_button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/property_entities.dart';

class EnquireSheet extends StatelessWidget {
  const EnquireSheet({
    super.key,
    required this.property,
    required this.formatWhatsApp,
  });
  final Property property;
  final String Function(String) formatWhatsApp;

  @override
  Widget build(BuildContext context) {
    final contact = property.contact;
    final waPhone = contact.whatsapp ?? contact.phone;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Gap(20),

              // Contact avatar + name
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primary100,
                    child: Text(
                      contact.name.isNotEmpty
                          ? contact.name[0].toUpperCase()
                          : '?',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Gap(14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(contact.name, style: AppTextStyles.h4),
                        Text(
                          contact.role == 'AGENT'
                              ? 'Property Agent'
                              : 'Property Owner',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Gap(24),
              const Divider(height: 1),
              const Gap(16),

              Text(
                'How would you like to contact ${contact.name.split(' ').first}?',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const Gap(16),

              // WhatsApp button
              ContactButton(
                color: const Color(0xFF25D366),
                icon: Icons.chat_bubble_rounded,
                title: 'Message on WhatsApp',
                subtitle: 'Fastest response · ${contact.phone}',
                onTap: () async {
                  context.pop();
                  final url = Uri.parse(
                    'https://wa.me/${formatWhatsApp(waPhone)}'
                    '?text=Hi, I am inquiring about: ${property.title} on Rentora Houselink.',
                  );
                  if (await canLaunchUrl(url)) {
                    launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
              ),

              const Gap(10),

              // Call button
              ContactButton(
                color: AppColors.primary,
                icon: Icons.call_rounded,
                title: 'Phone Call',
                subtitle: contact.phone,
                onTap: () async {
                  context.pop();
                  final url = Uri.parse('tel:${contact.phone}');
                  if (await canLaunchUrl(url)) launchUrl(url);
                },
              ),
            ],
          ),
        ),
      ),
    ).animate().slideY(
      begin: 0.2,
      end: 0,
      duration: 300.ms,
      curve: Curves.easeOut,
    );
  }
}
