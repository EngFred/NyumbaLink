import 'package:flutter/material.dart';

import 'package:rentora/features/properties/presentation/widgets/property-detail/hero_image_carousel.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/hero_video_hero.dart';
import '../../../domain/entities/property_entities.dart';

/// Selects the correct hero-media widget based on what a property has:
///
/// | Images | Videos | Hero shown          |
/// |--------|--------|---------------------|
/// | ✓      | any    | [HeroImageCarousel] |
/// | ✗      | ✓      | [HeroVideoHero]     |
/// | ✗      | ✗      | [HeroImageCarousel] (falls through to [HeroFallback]) |
class HeroCarousel extends StatelessWidget {
  const HeroCarousel({
    super.key,
    required this.property,
    required this.onPageChanged,
    required this.onViewAllTap,
  });

  final Property property;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onViewAllTap;

  @override
  Widget build(BuildContext context) {
    if (property.images.isEmpty && property.videos.isNotEmpty) {
      return HeroVideoHero(property: property);
    }

    return HeroImageCarousel(
      property: property,
      onPageChanged: onPageChanged,
      onViewAllTap: onViewAllTap,
    );
  }
}
