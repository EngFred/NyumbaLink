import '../entities/university.dart';

abstract class UniversitiesRepository {
  Future<List<University>> getUniversities();
}
