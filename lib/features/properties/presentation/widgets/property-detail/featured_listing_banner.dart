import 'package:flutter/material.dart';

class FeaturedListingBanner extends StatelessWidget {
  const FeaturedListingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFD4A017), Color(0xFFF0C040)],
        ),
      ),
      alignment: Alignment.center,
      child: const Text(
        '★   Featured Listing',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
