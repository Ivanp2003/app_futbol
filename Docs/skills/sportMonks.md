# Agente - Integración de SportMonks v3 (Livescores Inplay)

Actúa como un desarrollador móvil experto en Flutter, UI/UX y Clean Architecture. Tu objetivo es migrar el origen de datos actual de la aplicación al proveedor **SportMonks v3**, específicamente para consumir los partidos en vivo (`inplay`) utilizando las mejores prácticas de desacoplamiento y tipado estricto.

---

## 🛠️ 1. Configuración del Núcleo (`Core Layer`)

### Cliente HTTP Centralizado (`DioClient`)
Modifica `lib/core/network/dio_client.dart` para apuntar a la URL base de SportMonks v3 e inyectar el token de autenticación (Bearer Token) en los headers.

```dart
// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio;

  DioClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: '[https://api.sportmonks.com/v3/football](https://api.sportmonks.com/v3/football)',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'Authorization': 'TU_SPORTMONKS_API_TOKEN_AQUI',
              'Accept': 'application/json',
            },
          ),
        );

  Dio get dio => _dio;
}
⚽ 2. Mapeo de Datos & Feature Layer (Matches Board)
Estructura de Respuesta Esperada (SportMonks v3 JSON)
SportMonks v3 envuelve sus respuestas en un nodo principal llamado data. Cada objeto partido (fixture) contiene sub-nodos relacionales para los equipos (participants) y los periodos de tiempo (periods).

Adaptación del Modelo (MatchModel)
Refactoriza el factory fromJson en lib/features/matches_board/data/models/match_model.dart para procesar la nueva estructura. Mapea dinámicamente los campos calculando si el partido está activo (inplay).

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
    // SportMonks v3 agrupa los equipos en la lista 'participants'
    final participants = json['participants'] as List? ?? [];
    
    final homeData = participants.firstWhere((p) => p['meta']?['location'] == 'home', orElse: () => {});
    final awayData = participants.firstWhere((p) => p['meta']?['location'] == 'away', orElse: () => {});
    
    // Puntuaciones (Scores)
    final scores = json['scores'] as List? ?? [];
    final homeScoreObj = scores.firstWhere((s) => s['description'] == 'CURRENT' && s['participant_id'] == homeData['id'], orElse: () => {});
    final awayScoreObj = scores.firstWhere((s) => s['description'] == 'CURRENT' && s['participant_id'] == awayData['id'], orElse: () => {});

    // Estado y Minuto en Vivo
    final state = json['state']?['state'] as String? ?? 'NS';
    final bool liveActive = state == 'INPLAY' || state == 'LIVE';

    return MatchModel(
      id: json['id'].toString(),
      homeTeam: homeData['name'] as String? ?? 'Local',
      awayTeam: awayData['name'] as String? ?? 'Visitante',
      homeLogo: homeData['image_path'] as String? ?? '',
      awayLogo: awayData['image_path'] as String? ?? '',
      homeGoals: homeScoreObj['score']?['goals'] as int?,
      awayGoals: awayScoreObj['score']?['goals'] as int?,
      status: state,
      stadium: json['venue']?['name'] as String? ?? 'Estadio por definir',
      stage: json['stage']?['name'] as String? ?? 'Fase de Grupos',
      group: json['group']?['name'] as String?,
      utcDateTime: DateTime.parse(json['starting_at'] as String),
      isLive: liveActive,
      minute: json['minute'] as int?,
    );
  }
}
📡 3. Origen de Datos Remoto (Data Source)
Refactoriza lib/features/matches_board/data/datasources/matches_remote_datasource.dart. Implementa el nuevo endpoint /livescores/inplay e incluye el parámetro include=participants;scores;venue;stage;group para traer todas las relaciones necesarias en una sola petición y evitar datos nulos en la interfaz.

Dart
// lib/features/matches_board/data/datasources/matches_remote_datasource.dart
import 'package:dio/dio.dart';
import '../models/match_model.dart';

class MatchesRemoteDataSource {
  final Dio dio;

  MatchesRemoteDataSource(this.dio);

  Future<List<MatchModel>> getLiveMatches() async {
    try {
      // Endpoint oficial de SportMonks v3 para partidos en juego
      final response = await dio.get(
        '/livescores/inplay',
        queryParameters: {
          'include': 'participants;scores;venue;stage;group',
        },
      );

      // SportMonks siempre encapsula el resultado en la raíz 'data'
      final List data = response.data['data'] ?? [];

      if (data.isEmpty) {
        return [];
      }

      return data.map((item) => MatchModel.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Fallo en SportMonks API: ${e.message}');
    } catch (e) {
      throw Exception('Error al procesar las estructuras en vivo.');
    }
  }
}
🎨 4. Ajustes en la Presentación (UI/UX Layer)
Flujo de HomeScreen: Modifica el llamado del repositorio para que en lugar de filtrar estrictamente por un string de fecha estática (getMatchesByDate), ejecute la nueva firma del método reactivo (getLiveMatches()).

Estados Vacíos Inteligentes: Si la lista devuelta por /livescores/inplay está vacía, asegúrate de actualizar el widget del centro para que muestre de forma elegante: "No hay partidos del Mundial en vivo en este momento", manteniendo la barra superior Magenta brillante.