import 'package:flutter/material.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/meta_chip.dart';

import '../../../../../core/utils/enum_helpers.dart';
import '../../../domain/entities/property_entities.dart';

class MetaChipsRow extends StatelessWidget {
  const MetaChipsRow({super.key, required this.property});
  final Property property;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (!property.isHostel) {
      chips.add(
        MetaChip(
          icon: Icons.meeting_room_outlined,
          label:
              '${property.numberOfRooms} ${property.numberOfRooms == 1 ? 'Room' : 'Rooms'}',
          highlighted: true,
        ),
      );
    }
    if (property.floor != null) {
      chips.add(
        MetaChip(icon: Icons.layers_outlined, label: 'Floor ${property.floor}'),
      );
    }
    if (property.hotelCategory != null) {
      chips.add(
        MetaChip(
          icon: Icons.star_border_rounded,
          label: property.hotelCategory!,
        ),
      );
    }
    if (property.furnishingStatus != null) {
      chips.add(
        MetaChip(
          icon: Icons.chair_outlined,
          label: FurnishingHelper.label(property.furnishingStatus!),
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
