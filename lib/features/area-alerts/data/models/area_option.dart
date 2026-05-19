/// Lightweight model used only for "Add Area" bottom sheet
class AreaOption {
  const AreaOption({
    required this.id,
    required this.name,
    required this.districtId,
    required this.districtName,
  });

  final String id;
  final String name;
  final String districtId;
  final String districtName;

  factory AreaOption.fromJson(Map<String, dynamic> json) {
    final district = json['district'] as Map<String, dynamic>? ?? {};
    return AreaOption(
      id: json['id'] as String,
      name: json['name'] as String,
      districtId: district['id'] as String? ?? '',
      districtName: district['name'] as String? ?? '',
    );
  }
}
