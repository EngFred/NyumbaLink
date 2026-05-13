class University {
  final String id;
  final String name;
  final String? shortName;
  final String? location;

  const University({
    required this.id,
    required this.name,
    this.shortName,
    this.location,
  });
}
