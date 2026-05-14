import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/property_entities.dart';

class CTABar extends StatelessWidget {
  const CTABar({
    super.key,
    required this.property,
    required this.onEnquire,
    required this.onBook,
  });
  final Property property;
  final VoidCallback onEnquire;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final canBook = property.isAvailable || property.isHostel;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
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
        child: Row(
          children: [
            OutlinedButton.icon(
              onPressed: onEnquire,
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 17),
              label: const Text('Enquire'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 50),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
            const Gap(12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: canBook ? onBook : null,
                icon: Icon(
                  property.isHostel
                      ? Icons.door_sliding_outlined
                      : Icons.calendar_month_outlined,
                  size: 17,
                ),
                label: Text(property.isHostel ? 'View Rooms' : 'Book Now'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(0, 50)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
