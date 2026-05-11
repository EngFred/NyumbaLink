import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/enum_helpers.dart';
import '../../domain/entities/property_entities.dart';
import '../providers/property_detail_provider.dart';
import '../providers/saved_properties_provider.dart';

// ── Page ─────────────────────────────────────────────────────────────────────

class PropertyDetailPage extends ConsumerStatefulWidget {
  const PropertyDetailPage({super.key, required this.propertyId});
  final String propertyId;

  @override
  ConsumerState<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends ConsumerState<PropertyDetailPage> {
  final _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatWhatsApp(String phone) {
    String f = phone.replaceAll(RegExp(r'[\s\-\+]'), '');
    if (f.startsWith('0')) f = '256${f.substring(1)}';
    return f;
  }

  void _openGallery(List<PropertyImage> images) {
    if (images.isEmpty) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => _FullScreenGallery(
          images: images,
          initialIndex: _currentImageIndex,
        ),
      ),
    );
  }

  void _showEnquireSheet(Property property) {
    ref.read(propertyDetailProvider(widget.propertyId).notifier).enquire();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _EnquireSheet(property: property, formatWhatsApp: _formatWhatsApp),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(propertyDetailProvider(widget.propertyId));
    final isSaved = ref
        .watch(savedPropertiesProvider)
        .savedList
        .any((p) => p.id == widget.propertyId);

    if (state.isLoading) return const _DetailSkeleton();
    if (state.error != null || state.property == null) {
      return _DetailError(
        error: state.error,
        onRetry: () =>
            ref.read(propertyDetailProvider(widget.propertyId).notifier).load(),
      );
    }

    final property = state.property!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBodyBehindAppBar: true,
        body: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            // ── Hero ────────────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 360,
              pinned: true,
              stretch: true,
              backgroundColor: AppColors.surface,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              elevation: 0,
              scrolledUnderElevation: 1,
              automaticallyImplyLeading: false,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: _CircleHeroButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => context.pop(),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: _CircleHeroButton(
                    icon: isSaved
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    iconColor: isSaved ? AppColors.error : Colors.white,
                    onTap: () {
                      ref
                          .read(savedPropertiesProvider.notifier)
                          .toggleSave(property);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isSaved ? 'Removed from saved' : 'Added to saved',
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 1),
                          backgroundColor: isSaved
                              ? AppColors.grey700
                              : AppColors.success,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    },
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                stretchModes: const [StretchMode.zoomBackground],
                background: _HeroCarousel(
                  property: property,
                  pageController: _pageController,
                  currentIndex: _currentImageIndex,
                  onPageChanged: (i) => setState(() => _currentImageIndex = i),
                  onTap: () => _openGallery(property.images),
                ),
              ),
            ),

            // ── Content ─────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _PropertyContent(
                property: property,
                onEnquire: () => _showEnquireSheet(property),
                onReport: () => context.push(
                  '/complaint',
                  extra: {
                    'propertyId': property.id,
                    'propertyTitle': property.title,
                  },
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _CTABar(
          property: property,
          onEnquire: () => _showEnquireSheet(property),
          onBook: () {
            if (property.isHostel) {
              context.push(
                AppRoutes.hostelRoomsPath(property.id),
                extra: property.title,
              );
            } else {
              context.push(
                AppRoutes.bookingPath(property.id),
                extra: {'title': property.title},
              );
            }
          },
        ),
      ),
    );
  }
}

// ── Hero carousel ─────────────────────────────────────────────────────────────

class _HeroCarousel extends StatelessWidget {
  const _HeroCarousel({
    required this.property,
    required this.pageController,
    required this.currentIndex,
    required this.onPageChanged,
    required this.onTap,
  });

  final Property property;
  final PageController pageController;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Images ──────────────────────────────────────────────────────────
        GestureDetector(
          onTap: onTap,
          child: property.images.isEmpty
              ? _HeroFallback(type: property.type)
              : PageView.builder(
                  controller: pageController,
                  onPageChanged: onPageChanged,
                  itemCount: property.images.length,
                  itemBuilder: (_, i) => CachedNetworkImage(
                    imageUrl: property.images[i].url,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        const ColoredBox(color: AppColors.grey100),
                    errorWidget: (_, __, ___) =>
                        _HeroFallback(type: property.type),
                  ),
                ),
        ),

        // ── Top scrim (for button readability) ──────────────────────────────
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 120,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xBB000000), Colors.transparent],
              ),
            ),
          ),
        ),

        // ── Bottom scrim (for info readability) ──────────────────────────────
        const Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 200,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xEE000000), Colors.transparent],
              ),
            ),
          ),
        ),

        // ── Bottom overlay: price + badges + dots ────────────────────────────
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dots
                if (property.images.length > 1) ...[
                  _CarouselDots(
                    count: property.images.length,
                    current: currentIndex,
                  ),
                  const Gap(14),
                ],

                // Type + Status badges
                Row(
                  children: [
                    _HeroBadge(
                      icon: PropertyTypeHelper.icon(property.type),
                      label: PropertyTypeHelper.label(property.type),
                    ),
                    const Gap(8),
                    _HeroStatusBadge(status: property.status),
                    if (property.images.length > 1) ...[
                      const Spacer(),
                      Text(
                        '${currentIndex + 1} / ${property.images.length}',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ],
                ),

                const Gap(8),

                // Price
                Text(
                  CurrencyFormatter.format(property.price),
                  style: AppTextStyles.priceLg.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                    shadows: [
                      const Shadow(blurRadius: 8, color: Colors.black45),
                    ],
                  ),
                ),
                const Gap(2),
                Text(
                  BillingCycleHelper.full(property.billingCycle),
                  style: AppTextStyles.labelSm.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroFallback extends StatelessWidget {
  const _HeroFallback({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary50, AppColors.primary100],
        ),
      ),
      child: Center(
        child: Icon(
          PropertyTypeHelper.icon(type),
          size: 80,
          color: AppColors.primary200,
        ),
      ),
    );
  }
}

class _CarouselDots extends StatelessWidget {
  const _CarouselDots({required this.count, required this.current});
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count > 8 ? 8 : count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(right: 5),
          width: isActive ? 22 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white38,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const Gap(5),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStatusBadge extends StatelessWidget {
  const _HeroStatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final isAvailable = status == 'AVAILABLE';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: isAvailable
            ? AppColors.success.withOpacity(0.88)
            : AppColors.grey700.withOpacity(0.88),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const Gap(5),
          Text(
            isAvailable ? 'Available' : 'Rented',
            style: AppTextStyles.labelSm.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleHeroButton extends StatelessWidget {
  const _CircleHeroButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.32),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(icon, color: iconColor ?? Colors.white, size: 20),
      ),
    );
  }
}

// ── Property content ──────────────────────────────────────────────────────────

class _PropertyContent extends StatefulWidget {
  const _PropertyContent({
    required this.property,
    required this.onEnquire,
    required this.onReport,
  });
  final Property property;
  final VoidCallback onEnquire;
  final VoidCallback onReport;

  @override
  State<_PropertyContent> createState() => _PropertyContentState();
}

class _PropertyContentState extends State<_PropertyContent> {
  bool _descExpanded = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          const _SheetHandle(),

          // Title + Location
          Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.title, style: AppTextStyles.h1),
                    const Gap(6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: AppColors.accent,
                        ),
                        const Gap(4),
                        Expanded(
                          child: Text(
                            '${p.area}, ${p.district.name}',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
              .animate(delay: 60.ms)
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.04, end: 0, duration: 300.ms),

          const Gap(16),

          // Meta chips
          if (_hasMeta(p))
            _MetaChipsRow(
              property: p,
            ).animate(delay: 100.ms).fadeIn(duration: 300.ms),

          const Gap(16),

          // Divider
          const Divider(
            indent: 20,
            endIndent: 20,
            height: 1,
            color: AppColors.grey200,
          ),

          const Gap(20),

          // Description
          _DescriptionSection(
            description: p.description,
            expanded: _descExpanded,
            onToggle: () => setState(() => _descExpanded = !_descExpanded),
          ).animate(delay: 140.ms).fadeIn(duration: 300.ms),

          // Amenities
          if (p.amenities != null && p.amenities!.isNotEmpty) ...[
            const Gap(20),
            const Divider(
              indent: 20,
              endIndent: 20,
              height: 1,
              color: AppColors.grey200,
            ),
            const Gap(20),
            _AmenitiesSection(
              amenities: p.amenities!,
            ).animate(delay: 180.ms).fadeIn(duration: 300.ms),
          ],

          // Details grid
          const Gap(20),
          const Divider(
            indent: 20,
            endIndent: 20,
            height: 1,
            color: AppColors.grey200,
          ),
          const Gap(20),
          _DetailsGrid(
            property: p,
          ).animate(delay: 220.ms).fadeIn(duration: 300.ms),

          // Engagement stats
          const Gap(20),
          const Divider(
            indent: 20,
            endIndent: 20,
            height: 1,
            color: AppColors.grey200,
          ),
          _EngagementStats(
            property: p,
          ).animate(delay: 260.ms).fadeIn(duration: 300.ms),

          // Report button
          const Gap(8),
          Center(
            child: TextButton.icon(
              onPressed: widget.onReport,
              icon: const Icon(
                Icons.flag_outlined,
                size: 16,
                color: AppColors.grey500,
              ),
              label: Text(
                'Report an issue with this property',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.grey500,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.grey400,
                ),
              ),
            ),
          ),

          const Gap(32),
        ],
      ),
    );
  }

  bool _hasMeta(Property p) =>
      !p.isHostel ||
      p.floor != null ||
      p.hotelCategory != null ||
      p.furnishingStatus != null;
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.grey300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _MetaChipsRow extends StatelessWidget {
  const _MetaChipsRow({required this.property});
  final Property property;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (!property.isHostel) {
      chips.add(
        _MetaChip(
          icon: Icons.meeting_room_outlined,
          label:
              '${property.numberOfRooms} ${property.numberOfRooms == 1 ? 'Room' : 'Rooms'}',
          highlighted: true,
        ),
      );
    }
    if (property.floor != null) {
      chips.add(
        _MetaChip(
          icon: Icons.layers_outlined,
          label: 'Floor ${property.floor}',
        ),
      );
    }
    if (property.totalFloors != null) {
      chips.add(
        _MetaChip(
          icon: Icons.apartment_outlined,
          label: '${property.totalFloors} Floors',
        ),
      );
    }
    if (property.hotelCategory != null) {
      chips.add(
        _MetaChip(
          icon: Icons.star_border_rounded,
          label: property.hotelCategory!,
        ),
      );
    }
    if (property.furnishingStatus != null) {
      chips.add(
        _MetaChip(
          icon: Icons.chair_outlined,
          label: FurnishingHelper.label(property.furnishingStatus!),
        ),
      );
    }
    if (property.residentialSubtype != null) {
      chips.add(
        _MetaChip(
          icon: Icons.home_outlined,
          label: ResidentialSubtypeHelper.label(property.residentialSubtype!),
        ),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: chips
            .map(
              (c) =>
                  Padding(padding: const EdgeInsets.only(right: 8), child: c),
            )
            .toList(),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    this.highlighted = false,
  });
  final IconData icon;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.primary50 : AppColors.grey100,
        borderRadius: BorderRadius.circular(10),
        border: highlighted
            ? Border.all(color: AppColors.primary.withOpacity(0.3))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: highlighted ? AppColors.primary : AppColors.grey600,
          ),
          const Gap(6),
          Text(
            label,
            style: AppTextStyles.labelMd.copyWith(
              color: highlighted ? AppColors.primary : AppColors.grey700,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({
    required this.description,
    required this.expanded,
    required this.onToggle,
  });
  final String description;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    const maxLines = 3;
    final isLong = description.length > 200;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Description', style: AppTextStyles.h3),
          const Gap(10),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Text(
              description,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
            secondChild: Text(
              description,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ),
          if (isLong) ...[
            const Gap(6),
            GestureDetector(
              onTap: onToggle,
              child: Text(
                expanded ? 'Show less ↑' : 'Read more ↓',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AmenitiesSection extends StatelessWidget {
  const _AmenitiesSection({required this.amenities});
  final List<String> amenities;

  static IconData _iconFor(String amenity) {
    final lower = amenity.toLowerCase();
    if (lower.contains('wifi') || lower.contains('internet')) {
      return Icons.wifi_rounded;
    }
    if (lower.contains('water')) return Icons.water_drop_outlined;
    if (lower.contains('electric') || lower.contains('power')) {
      return Icons.bolt_outlined;
    }
    if (lower.contains('parking') || lower.contains('car')) {
      return Icons.local_parking_rounded;
    }
    if (lower.contains('security') || lower.contains('guard')) {
      return Icons.security_rounded;
    }
    if (lower.contains('gym') || lower.contains('fitness')) {
      return Icons.fitness_center_rounded;
    }
    if (lower.contains('pool') || lower.contains('swimming')) {
      return Icons.pool_rounded;
    }
    if (lower.contains('tv') || lower.contains('cable')) {
      return Icons.tv_outlined;
    }
    if (lower.contains('gas') || lower.contains('kitchen')) {
      return Icons.kitchen_outlined;
    }
    if (lower.contains('laundry') || lower.contains('washing')) {
      return Icons.local_laundry_service_outlined;
    }
    return Icons.check_circle_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Amenities', style: AppTextStyles.h3),
          const Gap(12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: amenities.map((a) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_iconFor(a), size: 14, color: AppColors.primary),
                    const Gap(6),
                    Text(
                      a,
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.grey700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DetailsGrid extends StatelessWidget {
  const _DetailsGrid({required this.property});
  final Property property;

  @override
  Widget build(BuildContext context) {
    final rows = <_DetailRowData>[];

    rows.add(
      _DetailRowData(
        icon: PropertyTypeHelper.icon(property.type),
        label: 'Property Type',
        value: PropertyTypeHelper.label(property.type),
      ),
    );
    if (property.residentialSubtype != null) {
      rows.add(
        _DetailRowData(
          icon: Icons.home_outlined,
          label: 'Subtype',
          value: ResidentialSubtypeHelper.label(property.residentialSubtype!),
        ),
      );
    }
    if (property.billingCycle != null) {
      rows.add(
        _DetailRowData(
          icon: Icons.calendar_today_outlined,
          label: 'Billing Cycle',
          value: BillingCycleHelper.full(property.billingCycle),
        ),
      );
    }
    if (property.furnishingStatus != null) {
      rows.add(
        _DetailRowData(
          icon: Icons.chair_outlined,
          label: 'Furnishing',
          value: FurnishingHelper.label(property.furnishingStatus!),
        ),
      );
    }
    if (property.floor != null) {
      rows.add(
        _DetailRowData(
          icon: Icons.layers_outlined,
          label: 'Floor',
          value:
              '${property.floor}${property.totalFloors != null ? ' of ${property.totalFloors}' : ''}',
        ),
      );
    }
    if (property.isHostel && property.totalRooms != null) {
      rows.add(
        _DetailRowData(
          icon: Icons.hotel_outlined,
          label: 'Total Rooms',
          value: '${property.totalRooms}',
        ),
      );
    }
    if (property.hotelCategory != null) {
      rows.add(
        _DetailRowData(
          icon: Icons.star_border_rounded,
          label: 'Category',
          value: property.hotelCategory!,
        ),
      );
    }
    rows.add(
      _DetailRowData(
        icon: Icons.location_city_outlined,
        label: 'District',
        value: property.district.name,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Property Details', style: AppTextStyles.h3),
          const Gap(12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.grey200),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rows.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                color: AppColors.grey200,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (_, i) {
                final row = rows[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(row.icon, size: 18, color: AppColors.grey500),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          row.label,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        row.value,
                        style: AppTextStyles.labelMd.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRowData {
  const _DetailRowData({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;
}

class _EngagementStats extends StatelessWidget {
  const _EngagementStats({required this.property});
  final Property property;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _StatPill(
            icon: Icons.visibility_outlined,
            label: '${property.viewCount} views',
          ),
          const Gap(12),
          _StatPill(
            icon: Icons.chat_bubble_outline_rounded,
            label: '${property.enquiryCount} enquiries',
          ),
          const Spacer(),
          Text(
            _formatDate(property.createdAt),
            style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return 'Listed ${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.grey500),
          const Gap(5),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── CTA bar ───────────────────────────────────────────────────────────────────

class _CTABar extends StatelessWidget {
  const _CTABar({
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

// ── Enquire sheet ─────────────────────────────────────────────────────────────

class _EnquireSheet extends StatelessWidget {
  const _EnquireSheet({required this.property, required this.formatWhatsApp});
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
              _ContactButton(
                color: const Color(0xFF25D366),
                icon: Icons.chat_bubble_rounded,
                title: 'Message on WhatsApp',
                subtitle: 'Fastest response · ${contact.phone}',
                onTap: () async {
                  context.pop();
                  final url = Uri.parse(
                    'https://wa.me/${formatWhatsApp(waPhone)}'
                    '?text=Hi, I am inquiring about: ${property.title} on NyumbaLink.',
                  );
                  if (await canLaunchUrl(url)) {
                    launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
              ),

              const Gap(10),

              // Call button
              _ContactButton(
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

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.06),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelLg.copyWith(color: color),
                    ),
                    const Gap(2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: color.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Full-screen gallery ───────────────────────────────────────────────────────

class _FullScreenGallery extends StatefulWidget {
  const _FullScreenGallery({required this.images, required this.initialIndex});
  final List<PropertyImage> images;
  final int initialIndex;

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.images.length}',
          style: AppTextStyles.labelLg.copyWith(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: PhotoViewGallery.builder(
        itemCount: widget.images.length,
        pageController: PageController(initialPage: widget.initialIndex),
        onPageChanged: (i) => setState(() => _currentIndex = i),
        builder: (_, i) => PhotoViewGalleryPageOptions(
          imageProvider: CachedNetworkImageProvider(widget.images[i].url),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2.5,
        ),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        loadingBuilder: (_, __) => const Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
      ),
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _SkeletonBox(height: 360, radius: 0),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(height: 28, width: 260, radius: 8),
                SizedBox(height: 10),
                _SkeletonBox(height: 16, width: 180, radius: 6),
                SizedBox(height: 24),
                Row(
                  children: [
                    _SkeletonBox(height: 32, width: 90, radius: 10),
                    SizedBox(width: 8),
                    _SkeletonBox(height: 32, width: 80, radius: 10),
                    SizedBox(width: 8),
                    _SkeletonBox(height: 32, width: 70, radius: 10),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.height,
    this.width = double.infinity,
    required this.radius,
  });
  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ── Error ──────────────────────────────────────────────────────────────────────

class _DetailError extends StatelessWidget {
  const _DetailError({this.error, required this.onRetry});
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.errorLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 38,
                  color: AppColors.error,
                ),
              ),
              const Gap(20),
              Text('Could not load property', style: AppTextStyles.h3),
              const Gap(8),
              Text(
                error ?? 'Check your connection and try again.',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(24),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
