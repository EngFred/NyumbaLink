/// Wraps the standard paginated envelope returned by all list endpoints:
/// { data: [...], meta: { total, page, limit, totalPages } }
class PaginatedResponse<T> {
  const PaginatedResponse({required this.data, required this.meta});

  final List<T> data;
  final PaginationMeta meta;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return PaginatedResponse(
      data: (json['data'] as List)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  bool get hasNextPage => meta.page < meta.totalPages;
}

class PaginationMeta {
  const PaginationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  final int total;
  final int page;
  final int limit;
  final int totalPages;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      // Safely parse everything
      total: int.tryParse(json['total'].toString()) ?? 0,
      page: int.tryParse(json['page'].toString()) ?? 1,
      limit: int.tryParse(json['limit'].toString()) ?? 10,
      totalPages: int.tryParse(json['totalPages'].toString()) ?? 1,
    );
  }
}
