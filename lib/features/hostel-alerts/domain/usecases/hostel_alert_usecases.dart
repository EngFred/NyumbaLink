import '../entities/hostel_alert.dart';
import '../repositories/hostel_alert_repository.dart';

class SubscribeToHostelAlert {
  final HostelAlertRepository repository;
  const SubscribeToHostelAlert(this.repository);

  Future<HostelAlert> call(String propertyId) =>
      repository.subscribe(propertyId);
}

class UnsubscribeFromHostelAlert {
  final HostelAlertRepository repository;
  const UnsubscribeFromHostelAlert(this.repository);

  Future<void> call(String propertyId) => repository.unsubscribe(propertyId);
}

class GetMyHostelAlerts {
  final HostelAlertRepository repository;
  const GetMyHostelAlerts(this.repository);

  Future<List<HostelAlert>> call() => repository.getMyAlerts();
}
