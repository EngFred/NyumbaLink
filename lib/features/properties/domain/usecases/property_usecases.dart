import '../../../../core/network/paginated_response.dart';
import '../entities/property_entities.dart';
import '../entities/property_filters.dart';
import '../repositories/property_repository.dart';

class GetPropertiesUseCase {
  const GetPropertiesUseCase(this._repo);
  final PropertyRepository _repo;

  Future<PaginatedResponse<Property>> call(PropertyFilters filters) =>
      _repo.getProperties(filters);
}

class GetPropertyDetailsUseCase {
  const GetPropertyDetailsUseCase(this._repo);
  final PropertyRepository _repo;

  Future<Property> call(String id) => _repo.getPropertyDetails(id);
}

class IncrementEnquiryUseCase {
  const IncrementEnquiryUseCase(this._repo);
  final PropertyRepository _repo;

  Future<void> call(String id) => _repo.incrementEnquiry(id);
}

class GetHostelRoomsUseCase {
  const GetHostelRoomsUseCase(this._repo);
  final PropertyRepository _repo;

  Future<List<HostelRoom>> call(String propertyId) =>
      _repo.getHostelRooms(propertyId);
}

class GetHostelStatsUseCase {
  const GetHostelStatsUseCase(this._repo);
  final PropertyRepository _repo;

  Future<HostelStats> call(String propertyId) =>
      _repo.getHostelStats(propertyId);
}
