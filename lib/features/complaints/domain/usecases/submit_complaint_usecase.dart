import '../entities/complaint_entities.dart';
import '../repositories/complaint_repository.dart';

class SubmitComplaintUseCase {
  const SubmitComplaintUseCase(this._repo);

  final ComplaintRepository _repo;

  Future<void> call(ComplaintRequest request) {
    return _repo.submitComplaint(request);
  }
}
