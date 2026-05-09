import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/paginated_response.dart';
import '../../domain/entities/property_entities.dart';
import '../../domain/entities/property_filters.dart';
import '../../domain/repositories/property_repository.dart';
import '../datasources/properties_remote_datasource.dart';
import '../mappers/property_mapper.dart';

final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  return PropertyRepositoryImpl(ref.watch(propertiesDataSourceProvider));
});

class PropertyRepositoryImpl implements PropertyRepository {
  const PropertyRepositoryImpl(this._dataSource);
  final PropertiesRemoteDataSource _dataSource;

  @override
  Future<PaginatedResponse<Property>> getProperties(
    PropertyFilters filters,
  ) async {
    final response = await _dataSource.getProperties(filters.toMap());
    return PaginatedResponse(
      data: response.data.map((m) => m.toEntity()).toList(),
      meta: response.meta,
    );
  }

  @override
  Future<Property> getPropertyDetails(String id) async {
    final model = await _dataSource.getProperty(id);
    return model.toEntity();
  }

  @override
  Future<void> incrementEnquiry(String id) async {
    await _dataSource.incrementEnquiry(id);
  }

  @override
  Future<List<HostelRoom>> getHostelRooms(String propertyId) async {
    final models = await _dataSource.getHostelRooms(propertyId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<HostelStats> getHostelStats(String propertyId) async {
    final model = await _dataSource.getHostelStats(propertyId);
    return model.toEntity();
  }
}
