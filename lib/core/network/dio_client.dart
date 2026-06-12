// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio;

  DioClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://api.football-data.org/v4',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'X-Auth-Token': '7bb9e5231a5e4366a120849e1e69e96a',
            },
          ),
        );

  Dio get dio => _dio;
}