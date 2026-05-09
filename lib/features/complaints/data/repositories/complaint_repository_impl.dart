import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/complaint_entities.dart';
import '../../domain/repositories/complaint_repository.dart';
import '../datasources/complaints_remote_datasource.dart';
import '../models/complaint_models.dart';

final complaintRepositoryProvider = Provider<ComplaintRepository>((ref) {
  return ComplaintRepositoryImpl(ref.watch(complaintsRemoteDataSourceProvider));
});

class ComplaintRepositoryImpl implements ComplaintRepository {
  const ComplaintRepositoryImpl(this._remoteDataSource);

  final ComplaintsRemoteDataSource _remoteDataSource;

  @override
  Future<void> submitComplaint(ComplaintRequest request) async {
    await _remoteDataSource.submitComplaint(request.toJson());
  }
}
