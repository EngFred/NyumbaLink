class AreaAlert {
  const AreaAlert({
    required this.areaId,
    required this.areaName,
    required this.districtName,
    required this.createdAt,
    this.propertyTypes, // null = all types
  });

  final String areaId;
  final String areaName;
  final String districtName;
  final DateTime createdAt;

  /// The property types this subscription watches.
  /// null or empty = all types.
  final List<String>? propertyTypes;

  bool get isAllTypes => propertyTypes == null || propertyTypes!.isEmpty;
}
