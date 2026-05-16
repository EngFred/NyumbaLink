class PropertyFilters {
  const PropertyFilters({
    this.type,
    this.districtId,
    this.universityId,
    this.minPrice,
    this.maxPrice,
    this.numberOfRooms,
    this.search,
    this.status = 'AVAILABLE',
    this.isFeatured,
    this.sortBy,
    this.sortOrder,
    this.page = 1,
    this.limit = 15,
  });

  final String? type;
  final String? districtId;
  final String? universityId;
  final double? minPrice;
  final double? maxPrice;
  final int? numberOfRooms;
  final String? search;
  final String? status;
  final bool? isFeatured;

  /// Field to sort results by.
  /// Allowed values: 'createdAt' | 'price' | 'viewCount' | 'enquiryCount'
  /// Default on the backend is 'createdAt'.
  /// Pass 'viewCount' to get "most popular" listings.
  final String? sortBy;

  /// Sort direction: 'ASC' | 'DESC'. Backend defaults to 'DESC'.
  final String? sortOrder;

  final int page;
  final int limit;

  PropertyFilters copyWith({
    String? type,
    String? districtId,
    String? universityId,
    double? minPrice,
    double? maxPrice,
    int? numberOfRooms,
    String? search,
    String? status,
    bool? isFeatured,
    String? sortBy,
    String? sortOrder,
    int? page,
    int? limit,
    bool clearType = false,
    bool clearDistrictId = false,
    bool clearUniversityId = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearNumberOfRooms = false,
    bool clearSearch = false,
    bool clearIsFeatured = false,
    bool clearSortBy = false,
    bool clearSortOrder = false,
  }) {
    return PropertyFilters(
      type: clearType ? null : (type ?? this.type),
      districtId: clearDistrictId ? null : (districtId ?? this.districtId),
      universityId: clearUniversityId
          ? null
          : (universityId ?? this.universityId),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      numberOfRooms: clearNumberOfRooms
          ? null
          : (numberOfRooms ?? this.numberOfRooms),
      search: clearSearch ? null : (search ?? this.search),
      status: status ?? this.status,
      isFeatured: clearIsFeatured ? null : (isFeatured ?? this.isFeatured),
      sortBy: clearSortBy ? null : (sortBy ?? this.sortBy),
      sortOrder: clearSortOrder ? null : (sortOrder ?? this.sortOrder),
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  bool get hasActiveFilters =>
      type != null ||
      districtId != null ||
      universityId != null ||
      minPrice != null ||
      maxPrice != null ||
      numberOfRooms != null ||
      (search != null && search!.isNotEmpty);

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{'page': page, 'limit': limit};

    if (type != null) map['type'] = type;
    if (districtId != null) map['districtId'] = districtId;
    if (universityId != null) map['universityId'] = universityId;
    if (minPrice != null) map['minPrice'] = minPrice;
    if (maxPrice != null) map['maxPrice'] = maxPrice;
    if (numberOfRooms != null) map['numberOfRooms'] = numberOfRooms;
    if (search != null && search!.isNotEmpty) map['search'] = search;
    if (status != null) map['status'] = status;
    if (isFeatured != null) map['isFeatured'] = isFeatured;
    if (sortBy != null) map['sortBy'] = sortBy;
    if (sortOrder != null) map['sortOrder'] = sortOrder;

    return map;
  }
}
