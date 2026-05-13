import '../repositories/universities_repository.dart';
import '../entities/university.dart';

class GetUniversities {
  final UniversitiesRepository _repository;

  const GetUniversities(this._repository);

  Future<List<University>> call() => _repository.getUniversities();
}
