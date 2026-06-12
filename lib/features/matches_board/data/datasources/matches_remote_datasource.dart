// lib/features/matches_board/data/datasources/matches_remote_datasource.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/match_model.dart';

class MatchesRemoteDataSource {
  final Dio dio;

  MatchesRemoteDataSource(this.dio);

  Future<List<MatchModel>> getMatchesByDate(String dateStr) async {
    try {
      // football-data.org filtra por rangos de fecha usando dateFrom y dateTo
      // Usamos el endpoint específico de la competición (FIFA World Cup ID: 2000)
      // porque el endpoint genérico /matches no devuelve datos en el plan gratuito TIER_ONE
      final response = await dio.get('/competitions/2000/matches', queryParameters: {
        'dateFrom': dateStr,
        'dateTo': dateStr,
      });

      final List data = response.data['matches'] ?? [];

      // Si la API responde exitosamente pero no hay partidos, devolvemos la lista vacía []
      // Esto disparará el mensaje 'No hay partidos del Mundial en esta fecha' en la UI
      if (data.isEmpty) {
        return [];
      }

      return data.map((item) {
        return MatchModel.fromJson(item as Map<String, dynamic>);
      }).toList();

    } on DioException catch (e) {
      // En lugar de ocultar el error con un mock, lo propagamos hacia arriba
      // para que el FutureBuilder muestre el mensaje de diagnóstico en la pantalla
      debugPrint('Error en petición Dio (football-data): ${e.message}');
      throw Exception('Error de red: ${e.type} - ${e.message}');
    } catch (e) {
      debugPrint('Error parseando datos reales de la API: $e');
      throw Exception('Error al procesar los datos del servidor de fútbol.');
    }
  }
}
