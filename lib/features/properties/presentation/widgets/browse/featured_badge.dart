import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rentora/features/properties/presentation/pages/browse_page.dart';

class FeaturedBadge extends StatelessWidget {
  const FeaturedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // UX Polish: Slightly adjusted padding for the new text length
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: kFeaturedGold,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kFeaturedGold.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // UX Polish: Swapped the text '★' for a clean, modern icon
          Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 12),
          Gap(4),
          Text(
            'Recommended',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
