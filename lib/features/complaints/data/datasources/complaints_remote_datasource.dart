import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';

final complaintsRemoteDataSourceProvider = Provider<ComplaintsRemoteDataSource>(
  (ref) {
    return ComplaintsRemoteDataSource(ref.watch(dioProvider));
  },
);

class ComplaintsRemoteDataSource {
  const ComplaintsRemoteDataSource(this._dio);
  final Dio _dio;

  Future<void> submitComplaint(Map<String, dynamic> data) async {
    try {
      await _dio.post('/complaints', data: data);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }
}
