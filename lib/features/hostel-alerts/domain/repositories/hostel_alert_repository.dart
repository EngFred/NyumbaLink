import '../entities/hostel_alert.dart';

abstract class HostelAlertRepository {
  Future<HostelAlert> subscribe(String propertyId);
  Future<void> unsubscribe(String propertyId);
  Future<List<HostelAlert>> getMyAlerts();
}
