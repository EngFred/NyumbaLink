import '../entities/area_alert.dart';

abstract class AreaAlertRepository {
  Future<List<AreaAlert>> getMyAlerts();
  Future<AreaAlert> subscribe(String areaId, {List<String>? propertyTypes});
  Future<void> unsubscribe(String areaId);
  Future<AreaAlert> update(String areaId, {List<String>? propertyTypes});
}
