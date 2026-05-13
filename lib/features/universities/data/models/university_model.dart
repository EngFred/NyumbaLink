class UniversityModel {
  final String id;
  final String name;
  final String? shortName;
  final String? location;

  const UniversityModel({
    required this.id,
    required this.name,
    this.shortName,
    this.location,
  });

  factory UniversityModel.fromJson(Map<String, dynamic> json) =>
      UniversityModel(
        id: json['id'] as String,
        name: json['name'] as String,
        shortName: json['shortName'] as String?,
        location: json['location'] as String?,
      );
}
