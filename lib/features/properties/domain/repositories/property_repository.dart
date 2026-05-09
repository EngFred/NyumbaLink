import '../../../../core/network/paginated_response.dart';
import '../entities/property_entities.dart';
import '../entities/property_filters.dart';

abstract class PropertyRepository {
  Future<PaginatedResponse<Property>> getProperties(PropertyFilters filters);
  Future<Property> getPropertyDetails(String id);
  Future<void> incrementEnquiry(String id);
  Future<List<HostelRoom>> getHostelRooms(String propertyId);
  Future<HostelStats> getHostelStats(String propertyId);
}
