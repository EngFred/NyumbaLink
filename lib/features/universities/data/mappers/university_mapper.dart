import '../../domain/entities/university.dart';
import '../models/university_model.dart';

class UniversityMapper {
  static University toEntity(UniversityModel model) => University(
    id: model.id,
    name: model.name,
    shortName: model.shortName,
    location: model.location,
  );

  static List<University> toEntityList(List<UniversityModel> models) =>
      models.map(toEntity).toList();
}
