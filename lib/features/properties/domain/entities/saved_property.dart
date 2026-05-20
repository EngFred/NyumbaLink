class SavedProperty {
  const SavedProperty({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.type,
    this.thumbnailUrl,
  });

  final String id;
  final String title;
  final double price;
  final String location;
  final String type;
  final String? thumbnailUrl;
}
