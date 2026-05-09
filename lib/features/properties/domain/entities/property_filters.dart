class PropertyFilters {
  const PropertyFilters({
    this.type,
    this.districtId,
    this.minPrice,
    this.maxPrice,
    this.bedrooms,
    this.status = 'AVAILABLE',
    this.page = 1,
    this.limit = 12,
  });

  final String? type;
  final String? districtId;
  final double? minPrice;
  final double? maxPrice;
  final int? bedrooms;
  final String? status;
  final int page;
  final int limit;

  PropertyFilters copyWith({
    String? type,
    String? districtId,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    String? status,
    int? page,
    int? limit,
    bool clearType = false,
    bool clearDistrictId = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearBedrooms = false,
  }) {
    return PropertyFilters(
      type: clearType ? null : (type ?? this.type),
      districtId: clearDistrictId ? null : (districtId ?? this.districtId),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      bedrooms: clearBedrooms ? null : (bedrooms ?? this.bedrooms),
      status: status ?? this.status,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  bool get hasActiveFilters =>
      type != null ||
      districtId != null ||
      minPrice != null ||
      maxPrice != null ||
      bedrooms != null;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{'page': page, 'limit': limit};
    if (type != null) map['type'] = type;
    if (districtId != null) map['districtId'] = districtId;
    if (minPrice != null) map['minPrice'] = minPrice;
    if (maxPrice != null) map['maxPrice'] = maxPrice;
    if (bedrooms != null) map['bedrooms'] = bedrooms;
    if (status != null) map['status'] = status;
    return map;
  }
}
