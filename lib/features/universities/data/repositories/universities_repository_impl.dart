import '../../domain/repositories/universities_repository.dart';
import '../../domain/entities/university.dart';
import '../datasources/universities_datasource.dart';
import '../mappers/university_mapper.dart';

class UniversitiesRepositoryImpl implements UniversitiesRepository {
  final UniversitiesRemoteDataSource _remoteDataSource;

  const UniversitiesRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<University>> getUniversities() async {
    final models = await _remoteDataSource.getUniversities();
    return UniversityMapper.toEntityList(models);
  }
}
