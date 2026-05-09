import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/enum_helpers.dart';
import '../providers/property_detail_provider.dart';

class PropertyDetailPage extends ConsumerStatefulWidget {
  const PropertyDetailPage({super.key, required this.propertyId});
  final String propertyId;

  @override
  ConsumerState<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends ConsumerState<PropertyDetailPage> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(propertyDetailProvider(widget.propertyId));

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.error != null || state.property == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(state.error ?? 'Property not found')),
      );
    }

    final property = state.property!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
              ),
              onPressed: () => context.pop(),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (property.images.isNotEmpty)
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 300,
                      viewportFraction: 1.0,
                      onPageChanged: (index, _) =>
                          setState(() => _currentImageIndex = index),
                    ),
                    items: property.images.map((img) {
                      return CachedNetworkImage(
                        imageUrl: img.url,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) =>
                            Container(color: AppColors.grey200),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      );
                    }).toList(),
                  ),
                  Positioned(
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentImageIndex + 1} / ${property.images.length}',
                        style: AppTextStyles.labelMd.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                height: 300,
                color: AppColors.primary50,
                child: Center(
                  child: Icon(
                    PropertyTypeHelper.icon(property.type),
                    size: 64,
                    color: AppColors.primary200,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          PropertyTypeHelper.label(property.type),
                          style: AppTextStyles.labelMd.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: PropertyStatusHelper.color(
                            property.status,
                            bg: true,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          PropertyStatusHelper.label(property.status),
                          style: AppTextStyles.labelMd.copyWith(
                            color: PropertyStatusHelper.color(property.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  Text(property.title, style: AppTextStyles.h1),
                  const Gap(8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 18,
                        color: AppColors.accent,
                      ),
                      const Gap(4),
                      Text(
                        '${property.area}, ${property.district.name}',
                        style: AppTextStyles.bodyLg,
                      ),
                    ],
                  ),
                  const Gap(24),
                  Text(
                    CurrencyFormatter.format(property.price),
                    style: AppTextStyles.priceLg,
                  ),
                  Text(
                    BillingCycleHelper.full(property.billingCycle),
                    style: AppTextStyles.bodySm,
                  ),
                  const Gap(24),
                  const Divider(),
                  const Gap(16),
                  Text('Description', style: AppTextStyles.h3),
                  const Gap(8),
                  Text(property.description, style: AppTextStyles.bodyMd),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ref
                      .read(propertyDetailProvider(widget.propertyId).notifier)
                      .enquire();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enquiry sent!')),
                  );
                },
                child: const Text('Enquire'),
              ),
            ),
            const Gap(16),
            Expanded(
              child: ElevatedButton(
                onPressed: property.isAvailable || property.isHostel
                    ? () {
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
                      }
                    : null,
                child: Text(property.isHostel ? 'View Rooms' : 'Book Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
