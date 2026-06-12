import 'package:dio/dio.dart';

abstract class DetailRemoteDataSource {
  Future<dynamic> getMatchDetail(String matchId);
}

class DetailRemoteDataSourceImpl implements DetailRemoteDataSource {
  final Dio dio;

  DetailRemoteDataSourceImpl({required this.dio});

  @override
  Future<dynamic> getMatchDetail(String matchId) async {
    try {
      final response = await dio.get('/matches/$matchId');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error al cargar detalle del partido');
      }
    } catch (e) {
      rethrow;
    }
  }
}
