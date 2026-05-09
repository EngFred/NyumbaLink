class ComplaintRequest {
  const ComplaintRequest({
    required this.submitterName,
    required this.submitterPhone,
    this.submitterEmail,
    required this.category,
    required this.description,
    this.propertyId,
  });

  final String submitterName;
  final String submitterPhone;
  final String? submitterEmail;
  final String category;
  final String description;
  final String? propertyId;
}
