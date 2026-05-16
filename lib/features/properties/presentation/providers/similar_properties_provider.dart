import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/property_entities.dart';
import '../../domain/entities/property_filters.dart';
import 'usecase_providers.dart';

/// Fetches up to 5 properties that share the same district AND type as [property],
/// excluding [property] itself. Falls back to a type-only search (dropping the
/// district constraint) when fewer than 3 same-district results are found.
///
/// Usage in a widget:
/// ```dart
/// final async = ref.watch(similarPropertiesProvider(property));
/// ```
final similarPropertiesProvider = FutureProvider.family
    .autoDispose<List<Property>, Property>((ref, property) async {
      final getProperties = ref.watch(getPropertiesUseCaseProvider);

      // ── Primary: same district + same type ──────────────────────────────────
      final primaryFilters = PropertyFilters(
        districtId: property.district.id,
        type: property.type,
        status: 'AVAILABLE',
        limit: 6,
        page: 1,
      );

      final primaryResult = await getProperties(primaryFilters);
      final primaryList = primaryResult.data
          .where((p) => p.id != property.id)
          .take(5)
          .toList();

      // If we already have 3+ results we're good — no need for a second call.
      if (primaryList.length >= 3) return primaryList;

      // ── Fallback: same type only (broader district) ──────────────────────────
      // Collect ids already fetched to avoid duplicates.
      final seenIds = {property.id, ...primaryList.map((p) => p.id)};
      final needed = 5 - primaryList.length;

      final fallbackFilters = PropertyFilters(
        type: property.type,
        status: 'AVAILABLE',
        limit: needed + seenIds.length, // over-fetch to account for dedup
        page: 1,
      );

      final fallbackResult = await getProperties(fallbackFilters);
      final fallbackList = fallbackResult.data
          .where((p) => !seenIds.contains(p.id))
          .take(needed)
          .toList();

      return [...primaryList, ...fallbackList];
    });
