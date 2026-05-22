import '../entities/area_alert.dart';
import '../repositories/area_alert_repository.dart';

class GetMyAreaAlerts {
  final AreaAlertRepository repository;
  const GetMyAreaAlerts(this.repository);

  Future<List<AreaAlert>> call() => repository.getMyAlerts();
}

class SubscribeToAreaAlert {
  const SubscribeToAreaAlert(this._repo);
  final AreaAlertRepository _repo;

  Future<AreaAlert> call(String areaId, {List<String>? propertyTypes}) =>
      _repo.subscribe(areaId, propertyTypes: propertyTypes);
}

class UnsubscribeFromAreaAlert {
  final AreaAlertRepository repository;
  const UnsubscribeFromAreaAlert(this.repository);

  Future<void> call(String areaId) => repository.unsubscribe(areaId);
}

class UpdateAreaAlert {
  const UpdateAreaAlert(this._repo);
  final AreaAlertRepository _repo;
  Future<AreaAlert> call(String areaId, {List<String>? propertyTypes}) =>
      _repo.update(areaId, propertyTypes: propertyTypes);
}
