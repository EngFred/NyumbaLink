import '../entities/area_alert.dart';

abstract class AreaAlertRepository {
  Future<List<AreaAlert>> getMyAlerts();
  Future<AreaAlert> subscribe(String areaId);
  Future<void> unsubscribe(String areaId);
}
