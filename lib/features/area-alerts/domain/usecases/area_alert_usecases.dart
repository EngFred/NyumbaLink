import '../entities/area_alert.dart';
import '../repositories/area_alert_repository.dart';

class GetMyAreaAlerts {
  final AreaAlertRepository repository;
  const GetMyAreaAlerts(this.repository);

  Future<List<AreaAlert>> call() => repository.getMyAlerts();
}

class SubscribeToAreaAlert {
  final AreaAlertRepository repository;
  const SubscribeToAreaAlert(this.repository);

  Future<AreaAlert> call(String areaId) => repository.subscribe(areaId);
}

class UnsubscribeFromAreaAlert {
  final AreaAlertRepository repository;
  const UnsubscribeFromAreaAlert(this.repository);

  Future<void> call(String areaId) => repository.unsubscribe(areaId);
}
