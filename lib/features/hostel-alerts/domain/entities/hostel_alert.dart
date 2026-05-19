class HostelAlert {
  const HostelAlert({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.createdAt,
  });

  final String id;
  final String propertyId;
  final String propertyTitle;
  final DateTime createdAt;
}
