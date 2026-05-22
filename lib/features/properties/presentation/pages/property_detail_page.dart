import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import 'package:rentora/features/properties/presentation/utils/property_mapper_ext.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/circle_hero_button.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/cta_bar.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/detail_skeleton.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/enquire_sheet.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/full_screen_gallery.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/hero_carousel.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/property_content.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/notification_permission_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/property_entities.dart';
import '../providers/property_detail_provider.dart';
import '../providers/saved_properties_provider.dart';
import '../../../hostel-alerts/presentation/providers/hostel_alerts_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

const _kPublicBaseUrl = 'https://rentora-houselink.vercel.app';

class PropertyDetailPage extends ConsumerStatefulWidget {
  const PropertyDetailPage({super.key, required this.propertyId});
  final String propertyId;

  @override
  ConsumerState<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends ConsumerState<PropertyDetailPage> {
  int _currentImageIndex = 0;

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

  void _shareProperty(Property property) {
    final publicUrl = '$_kPublicBaseUrl/p/${property.id}';
    final location = property.area == null
        ? property.district.name
        : '${property.area!.name}, ${property.district.name}';
    final shareText =
        '${property.title}\n'
        '$location\n\n'
        '$publicUrl';
    Share.share(shareText, subject: property.title);
  }

  Future<bool> _ensureNotificationPermission() async {
    if (await NotificationPermissionService.isGranted()) return true;
    if (await NotificationPermissionService.isNotDetermined()) {
      await NotificationPermissionService.requestPermission();
      return NotificationPermissionService.isGranted();
    }
    if (!mounted) return false;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Notifications blocked', style: AppTextStyles.h4),
        content: Text(
          'To receive room availability alerts, please enable notifications '
          'for Rentora in your device settings.',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Not now'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              NotificationPermissionService.openSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
    return false;
  }

  void _showAuthRequiredDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active_outlined,
                size: 28,
                color: AppColors.primary,
              ),
            ),
            const Gap(20),
            Text('Sign in for Alerts', style: AppTextStyles.h3),
            const Gap(8),
            Text(
              'Sign in to receive instant push notifications the moment rooms become available here.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const Gap(32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.push(AppRoutes.login);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const Gap(12),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                foregroundColor: AppColors.textSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Not Now',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleHostelAlert(Property property) async {
    if (!property.isHostel) return;

    final isAuthenticated = ref.read(authProvider).isAuthenticated;
    if (!isAuthenticated) {
      _showAuthRequiredDialog();
      return;
    }

    final isSubscribed = ref
        .read(hostelAlertsProvider)
        .isSubscribed(property.id);

    if (!isSubscribed) {
      final allowed = await _ensureNotificationPermission();
      if (!allowed || !mounted) return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isSubscribed ? 'Stop alerts?' : 'Get room alerts?',
          style: AppTextStyles.h4,
        ),
        content: Text(
          isSubscribed
              ? 'You will no longer receive notifications when new rooms become available in this hostel.'
              : 'You will be notified when new rooms are added or become available again.',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isSubscribed
                  ? AppColors.error
                  : AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isSubscribed ? 'Unsubscribe' : 'Subscribe'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final notifier = ref.read(hostelAlertsProvider.notifier);
    try {
      if (isSubscribed) {
        await notifier.unsubscribe(property.id);
        if (mounted) {
          AppSnackbar.success(context, 'Alerts disabled for ${property.title}');
        }
      } else {
        await notifier.subscribe(property.id);
        if (mounted) {
          AppSnackbar.success(context, 'You will now receive room alerts!');
        }
      }
    } on Exception catch (_) {
      if (mounted) {
        AppSnackbar.error(context, 'Something went wrong. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(propertyDetailProvider(widget.propertyId));
    final savedState = ref.watch(savedPropertiesProvider);
    final hostelState = ref.watch(hostelAlertsProvider);
    final isSaved = savedState.savedList.any((p) => p.id == widget.propertyId);

    if (state.isLoading) return const DetailSkeleton();

    // ── NEW PRO UX: Context-aware Error Handling ──
    if (state.error != null || state.property == null) {
      final isNotFound =
          state.error?.toLowerCase().contains('not found') == true;

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
          title: isNotFound ? 'Property Unavailable' : 'Connection Issue',
          message: isNotFound
              ? 'This property may have been removed, rented out, or is no longer available on Rentora.'
              : state.error ??
                    'We couldn\'t load the property details. Please check your connection.',
          icon: isNotFound ? Icons.search_off_rounded : Icons.cloud_off_rounded,
          buttonLabel: isNotFound ? 'Go Back' : 'Try Again',
          onRetry: () {
            if (isNotFound) {
              context.pop();
            } else {
              ref
                  .read(propertyDetailProvider(widget.propertyId).notifier)
                  .load();
            }
          },
        ),
      );
    }
    // ───────────────────────────────────────────────

    final property = state.property!;
    final isHostelSubscribed =
        property.isHostel && hostelState.isSubscribed(widget.propertyId);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBodyBehindAppBar: true,
        body: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
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
                if (property.isHostel)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: hostelState.isPending(property.id)
                        ? const _CircleLoadingButton()
                        : CircleHeroButton(
                            icon: isHostelSubscribed
                                ? Icons.notifications_rounded
                                : Icons.notifications_outlined,
                            iconColor: Colors.white,
                            onTap: () => _toggleHostelAlert(property),
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
                      final wasSaved = isSaved;
                      ref
                          .read(savedPropertiesProvider.notifier)
                          .toggleSave(property.toSavedProperty());
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              wasSaved
                                  ? 'Removed from saved collection'
                                  : 'Added to saved collection!',
                            ),
                          ),
                        );
                    },
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                stretchModes: const [StretchMode.zoomBackground],
                background: HeroCarousel(
                  property: property,
                  onPageChanged: (i) => setState(() => _currentImageIndex = i),
                  onViewAllTap: () => _openGallery(property.images),
                ),
              ),
            ),
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
                extra: {
                  'title': property.title,
                  'location': property.locationDisplay,
                  'imageUrl': property.thumbnailUrl,
                  'universityName': property.university?.name,
                },
              );
            } else {
              context.push(
                AppRoutes.bookingPath(property.id),
                extra: {
                  'title': property.title,
                  'price': property.price,
                  'location': property.locationDisplay,
                  'imageUrl': property.thumbnailUrl,
                  'billingCycle': property.billingCycle,
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class _CircleLoadingButton extends StatelessWidget {
  const _CircleLoadingButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        shape: BoxShape.circle,
      ),
      child: const Padding(
        padding: EdgeInsets.all(10),
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      ),
    );
  }
}
