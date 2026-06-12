import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio;

  DioClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://v3.football.api-sports.io',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'x-apisports-key': 'cd9d1924b5fe53d5d477f423cc4999ab',
            },
          ),
        );

  Dio get dio => _dio;
}