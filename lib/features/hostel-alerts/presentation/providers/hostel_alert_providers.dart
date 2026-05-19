import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/hostel_alerts_remote_datasource.dart';
import '../../data/repositories/hostel_alert_repository_impl.dart';
import '../../domain/repositories/hostel_alert_repository.dart';

final hostelAlertRepositoryProvider = Provider<HostelAlertRepository>((ref) {
  final dataSource = ref.watch(hostelAlertsRemoteDataSourceProvider);
  return HostelAlertRepositoryImpl(dataSource);
});
