import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/circle_hero_button.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/cta_bar.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/detail_skeleton.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/enquire_sheet.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/full_screen_gallery.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/hero_carousel.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/property_content.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../domain/entities/property_entities.dart';
import '../providers/property_detail_provider.dart';
import '../providers/saved_properties_provider.dart';

/// Public base URL for the admin/web portal.
/// This is the URL that gets shared — anyone with or without the app can open it.
const _kPublicBaseUrl = 'https://rentora-houselink-admin.vercel.app';

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
        pageBuilder: (_, __, ___) =>
            FullScreenGallery(images: images, initialIndex: _currentImageIndex),
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
          EnquireSheet(property: property, formatWhatsApp: _formatWhatsApp),
    );
  }

  /// Shares a property using the native share sheet.
  /// The URL points to the public web page — works for recipients who don't have
  /// the app installed (opens in browser) and those who do (deep link opens the app).
  void _shareProperty(Property property) {
    final publicUrl = '$_kPublicBaseUrl/p/${property.id}';
    final shareText =
        '${property.title}\n'
        '${property.area}, ${property.district.name}\n\n'
        '$publicUrl';

    Share.share(shareText, subject: property.title);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(propertyDetailProvider(widget.propertyId));
    final isSaved = ref
        .watch(savedPropertiesProvider)
        .savedList
        .any((p) => p.id == widget.propertyId);

    if (state.isLoading) return const DetailSkeleton();

    if (state.error != null || state.property == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: AppColors.textPrimary,
            onPressed: () => context.pop(),
          ),
        ),
        body: AppErrorState(
          message: state.error ?? 'Failed to load property details.',
          onRetry: () => ref
              .read(propertyDetailProvider(widget.propertyId).notifier)
              .load(),
        ),
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
                child: CircleHeroButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => context.pop(),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleHeroButton(
                    icon: Icons.share_outlined,
                    iconColor: Colors.white,
                    onTap: () => _shareProperty(property),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleHeroButton(
                    icon: isSaved
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    iconColor: isSaved ? AppColors.error : Colors.white,
                    onTap: () {
                      ref
                          .read(savedPropertiesProvider.notifier)
                          .toggleSave(property);
                      if (isSaved) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Removed from saved collection'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Added to saved collection!'),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                stretchModes: const [StretchMode.zoomBackground],
                background: HeroCarousel(
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
              child: PropertyContent(
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
        bottomNavigationBar: CTABar(
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
