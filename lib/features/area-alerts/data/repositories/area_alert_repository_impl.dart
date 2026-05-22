import '../../domain/repositories/area_alert_repository.dart';
import '../../domain/entities/area_alert.dart';
import '../datasources/area_alerts_remote_datasource.dart';

class AreaAlertRepositoryImpl implements AreaAlertRepository {
  final AreaAlertsRemoteDataSource remoteDataSource;

  const AreaAlertRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<AreaAlert>> getMyAlerts() async {
    final models = await remoteDataSource.getMyAlerts();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<AreaAlert> subscribe(
    String areaId, {
    List<String>? propertyTypes,
  }) async {
    final model = await remoteDataSource.subscribe(
      areaId,
      propertyTypes: propertyTypes,
    );
    return model.toEntity();
  }

  @override
  Future<void> unsubscribe(String areaId) async {
    await remoteDataSource.unsubscribe(areaId);
  }
}
