class AreaAlert {
  const AreaAlert({
    required this.id,
    required this.areaId,
    required this.areaName,
    required this.districtName,
    required this.createdAt,
  });

  final String id;
  final String areaId;
  final String areaName;
  final String districtName;
  final DateTime createdAt;
}
