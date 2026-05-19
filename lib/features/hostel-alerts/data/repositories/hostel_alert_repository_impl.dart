import '../../domain/repositories/hostel_alert_repository.dart';
import '../../domain/entities/hostel_alert.dart';
import '../datasources/hostel_alerts_remote_datasource.dart';

class HostelAlertRepositoryImpl implements HostelAlertRepository {
  final HostelAlertsRemoteDataSource remoteDataSource;

  const HostelAlertRepositoryImpl(this.remoteDataSource);

  @override
  Future<HostelAlert> subscribe(String propertyId) async {
    final model = await remoteDataSource.subscribe(propertyId);
    return model.toEntity();
  }

  @override
  Future<void> unsubscribe(String propertyId) async {
    await remoteDataSource.unsubscribe(propertyId);
  }

  @override
  Future<List<HostelAlert>> getMyAlerts() async {
    final models = await remoteDataSource.getMyAlerts();
    return models.map((m) => m.toEntity()).toList();
  }
}
