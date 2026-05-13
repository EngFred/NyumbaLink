import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/university_model.dart';

class UniversitiesRemoteDataSource {
  final Dio _dio;

  const UniversitiesRemoteDataSource(this._dio);

  Future<List<UniversityModel>> getUniversities() async {
    try {
      final res = await _dio.get<List<dynamic>>('/universities');
      return (res.data ?? [])
          .map((e) => UniversityModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }
}
