# Agente - Implementación de Calendario Oficial Mundial 2026 (SportMonks v3)

Actúa como un desarrollador móvil experto en Flutter y Clean Architecture. Tu objetivo es implementar la consulta del calendario completo (partidos jugados, en vivo y programados) del Mundial 2026 utilizando los IDs oficiales provistos por la documentación de SportMonks v3 (`League ID: 732`, `Season ID: 26618`).

---

## 📡 1. Capa de Datos (Data Layer)

### Refactorización del Data Source Remoto
Modifica `lib/features/matches_board/data/datasources/matches_remote_datasource.dart`. Reemplazaremos el endpoint genérico de fechas por el endpoint oficial de estructuras por temporada: `/schedules/seasons/26618`. 

Como el JSON de SportMonks anida los partidos dentro de `stages -> rounds -> fixtures`, procesaremos el árbol de nodos de manera eficiente y realizaremos un filtrado por la fecha (`dateStr`) seleccionada en la UI.

```dart
// lib/features/matches_board/data/datasources/matches_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/match_model.dart';

class MatchesRemoteDataSource {
  final Dio dio;

  MatchesRemoteDataSource(this.dio);

  Future<List<MatchModel>> getMatchesByDate(String dateStr) async {
    try {
      // Endpoint oficial de SportMonks para el calendario del Mundial 2026
      final response = await dio.get('/schedules/seasons/26618');
      
      final List stages = response.data['data'] ?? [];
      final List<MatchModel> allMatchesForDate = [];

      // Recorremos el árbol estructural del JSON oficial de SportMonks
      for (var stage in stages) {
        final List rounds = stage['rounds'] ?? [];
        for (var round in rounds) {
          final List fixtures = round['fixtures'] ?? [];
          for (var fixture in fixtures) {
            
            // Extraemos la fecha del fixture (Formato YYYY-MM-DD HH:mm:ss)
            final String startingAt = fixture['starting_at'] ?? '';
            
            if (startingAt.startsWith(dateStr)) {
              allMatchesForDate.add(
                MatchModel.fromJson(fixture as Map<String, dynamic>, stageName: stage['name'] ?? 'Mundial'),
              );
            }
          }
        }
      }

      return allMatchesForDate;

    } on DioException catch (e) {
      debugPrint('Error en SportMonks Schedule API: ${e.message}');
      throw Exception('Error de red: ${e.message}');
    } catch (e) {
      debugPrint('Error procesando el árbol de fixtures de SportMonks: $e');
      throw Exception('Error al procesar el calendario oficial.');
    }
  }
}
⚽ 2. Capa de Modelo (Model Mappings)
Adaptación del Factory de Mapeo (MatchModel)
Actualiza lib/features/matches_board/data/models/match_model.dart para procesar de manera exacta los campos clave del JSON de SportMonks (como la lista de participants, la validación de placeholder para fases eliminatorias y el nodo scores).

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
  });

  factory MatchModel.fromJson(Map<String, dynamic> json, {required String stageName}) {
    final participants = json['participants'] as List? ?? [];
    
    // Identificar Local y Visitante por su meta-localización
    final homeData = participants.firstWhere((p) => p['meta']?['location'] == 'home', orElse: () => {});
    final awayData = participants.firstWhere((p) => p['meta']?['location'] == 'away', orElse: () => {});

    // Scores (Manejo de goles si el partido ya se jugó o está en vivo)
    final scores = json['scores'] as List? ?? [];
    int? homeGoals;
    int? awayGoals;
    
    if (scores.isNotEmpty) {
      // Extraemos los goles del nodo de marcador de SportMonks si existen
      final homeScoreObj = scores.firstWhere((s) => s['participant_id'] == homeData['id'], orElse: () => null);
      final awayScoreObj = scores.firstWhere((s) => s['participant_id'] == awayData['id'], orElse: () => null);
      homeGoals = homeScoreObj?['score']?['goals'];
      awayGoals = awayScoreObj?['score']?['goals'];
    }

    // Estado del partido basado en reglas SportMonks
    final stateId = json['state_id']?.toString();
    final bool isLiveMatch = stateId == '2' || stateId == '3'; // IDs estándar de Live/Inplay

    return MatchModel(
      id: json['id'].toString(),
      // Si es un placeholder (ej: Clasificado de repesca), SportMonks manda el texto descriptivo
      homeTeam: homeData['short_code'] ?? homeData['name'] ?? 'TBD',
      awayTeam: awayData['short_code'] ?? awayData['name'] ?? 'TBD',
      homeLogo: homeData['image_path'] ?? '[https://cdn.sportmonks.com/images/soccer/team_placeholder.png](https://cdn.sportmonks.com/images/soccer/team_placeholder.png)',
      awayLogo: awayData['image_path'] ?? '[https://cdn.sportmonks.com/images/soccer/team_placeholder.png](https://cdn.sportmonks.com/images/soccer/team_placeholder.png)',
      homeGoals: homeGoals,
      awayGoals: awayGoals,
      status: isLiveMatch ? 'LIVE' : (homeGoals != null ? 'FT' : 'NS'),
      stadium: 'Sede Mundialista', // SportMonks vincula el venue_id, se puede resolver localmente
      stage: stageName,
      group: json['group_id'] != null ? 'Grupo' : null,
      utcDateTime: DateTime.parse(json['starting_at']),
      isLive: isLiveMatch,
    );
  }
}
🔍 3. Validación y Pruebas
Asegúrate de pasar en el Header de DioClient tu token de producción de SportMonks.

Ejecuta flutter clean && flutter pub get para reconstruir los árboles binarios.

Al abrir la app, selecciona en la barra superior o DatePicker el 17 de junio de 2026; la app consumirá el JSON real y te mostrará de forma nativa el partido "England vs Croatia" junto con sus marcadores y banderas oficiales directo desde el CDN de SportMonks.