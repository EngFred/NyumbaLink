import '../entities/complaint_entities.dart';

abstract class ComplaintRepository {
  Future<void> submitComplaint(ComplaintRequest request);
}
