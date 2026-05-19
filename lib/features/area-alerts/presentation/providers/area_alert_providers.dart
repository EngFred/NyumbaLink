import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/area_alerts_remote_datasource.dart';
import '../../data/repositories/area_alert_repository_impl.dart';
import '../../domain/repositories/area_alert_repository.dart';

final areaAlertRepositoryProvider = Provider<AreaAlertRepository>((ref) {
  final dataSource = ref.watch(areaAlertsRemoteDataSourceProvider);
  return AreaAlertRepositoryImpl(dataSource);
});
