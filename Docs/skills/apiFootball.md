# Agente - Migración Definitiva a API-FOOTBALL (API-Sports)

Actúa como un desarrollador móvil experto en Flutter. Debemos migrar la capa de datos de la aplicación a **API-FOOTBALL (v3)**, ya que su plan gratuito nos otorga acceso irrestricto al Mundial 2026 (League ID: 1), incluyendo soporte futuro para endpoints de Alineaciones y Estadísticas.

Aplica estrictamente las siguientes refactorizaciones:

## 🌐 1. Restaurar el Cliente HTTP
Modifica `lib/core/network/dio_client.dart` para usar el host directo de API-Sports con el token del usuario.

```dart
// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio;

  DioClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: '[https://v3.football.api-sports.io](https://v3.football.api-sports.io)',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'x-apisports-key': 'cd9d1924b5fe53d5d477f423cc4999ab',
            },
          ),
        );

  Dio get dio => _dio;
}
🗃️ 2. Mapeo del Modelo de Datos
Reescribe el factory fromJson en lib/features/matches_board/data/models/match_model.dart para adaptarlo a la estructura de respuesta de API-FOOTBALL.

Dart
// lib/features/matches_board/data/models/match_model.dart
import '../../domain/entities/match_entity.dart';

class MatchModel extends MatchEntity {
  MatchModel({
    required super.id,
    required super.homeTeam,
    required super.awayTeam,
    required super.homeLogo,
    required super.awayLogo,
    super.homeGoals,
    super.awayGoals,
    required super.status,
    required super.stadium,
    required super.stage,
    super.group,
    required super.utcDateTime,
    super.isLive,
    super.minute,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    final fixture = json['fixture'] as Map<String, dynamic>? ?? {};
    final teams = json['teams'] as Map<String, dynamic>? ?? {};
    final goals = json['goals'] as Map<String, dynamic>? ?? {};
    final league = json['league'] as Map<String, dynamic>? ?? {};

    // Determinar si está en vivo basado en el short status
    final shortStatus = fixture['status']?['short'] as String? ?? 'NS';
    final isLiveMatch = shortStatus == '1H' || shortStatus == '2H' || shortStatus == 'HT' || shortStatus == 'ET' || shortStatus == 'P' || shortStatus == 'LIVE';

    return MatchModel(
      id: fixture['id'].toString(),
      homeTeam: teams['home']?['name'] as String? ?? 'Local',
      awayTeam: teams['away']?['name'] as String? ?? 'Visitante',
      homeLogo: teams['home']?['logo'] as String? ?? '[https://media.api-sports.io/football/teams/default.png](https://media.api-sports.io/football/teams/default.png)',
      awayLogo: teams['away']?['logo'] as String? ?? '[https://media.api-sports.io/football/teams/default.png](https://media.api-sports.io/football/teams/default.png)',
      homeGoals: goals['home'] as int?,
      awayGoals: goals['away'] as int?,
      status: shortStatus,
      stadium: fixture['venue']?['name'] as String? ?? 'Sede por definir',
      stage: league['round'] as String? ?? 'Fase de Grupos',
      group: league['round'] != null && league['round'].toString().contains('Group') ? league['round'] : null,
      utcDateTime: DateTime.parse(fixture['date'] as String),
      isLive: isLiveMatch,
      minute: fixture['status']?['elapsed'] as int?,
    );
  }
}
📡 3. Modificación del Data Source Remoto
Actualiza lib/features/matches_board/data/datasources/matches_remote_datasource.dart para consultar el endpoint /fixtures usando el League ID 1 (Copa del Mundo) y la temporada 2026.

Dart
// lib/features/matches_board/data/datasources/matches_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/match_model.dart';

class MatchesRemoteDataSource {
  final Dio dio;

  MatchesRemoteDataSource(this.dio);

  Future<List<MatchModel>> getMatchesByDate(String dateStr) async {
    try {
      final response = await dio.get('/fixtures', queryParameters: {
        'league': '1', // ID oficial de la Copa del Mundo en API-FOOTBALL
        'season': '2026',
        'date': dateStr,
      });

      final List data = response.data['response'] ?? [];

      if (data.isEmpty) {
        return [];
      }

      return data.map((item) => MatchModel.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      debugPrint('Error de red API-FOOTBALL: ${e.message}');
      throw Exception('Error de red: ${e.message}');
    } catch (e) {
      debugPrint('Error procesando el JSON de API-FOOTBALL: $e');
      throw Exception('Error al procesar el calendario oficial.');
    }
  }
}

---

### ⚠️ Un detalle importante sobre las fechas en 2026
Al conectarnos a **API-FOOTBALL** y buscar el Mundial 2026, ten en cuenta que las APIs deportivas suelen cargar el calendario detallado oficial (con estadios y horarios exactos) unos meses antes del torneo (una vez que se realiza el sorteo de grupos). 

Si seleccionas una fecha aleatoria hoy y la API te devuelve la lista vacía (`No hay partidos del