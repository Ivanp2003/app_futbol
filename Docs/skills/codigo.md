🛠️ Stack Tecnológico & Configuración Core
Cliente HTTP Centralizado (Dio)
Gestiona los timeouts de red, headers obligatorios y la URL base de API-FOOTBALL (RapidAPI).

Dart
// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio;

  DioClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: '[https://api-football-v1.p.rapidapi.com/v3](https://api-football-v1.p.rapidapi.com/v3)',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'x-rapidapi-key': 'TU_API_KEY_AQUI', 
              'x-rapidapi-host': 'api-football-v1.p.rapidapi.com',
            },
          ),
        );

  Dio get dio => _dio;
}
⚽ Vertical Slice: Matches Board (HU-01 y HU-02)
1. Entidad del Dominio
Dart
// lib/features/matches_board/domain/entities/match_entity.dart
class MatchEntity {
  final String id;
  final String homeTeam;
  final String awayTeam;
  final String homeLogo;
  final String awayLogo;
  final int? homeGoals;
  final int? awayGoals;
  final String status;
  final String stadium;
  final String stage;
  final String? group;
  final DateTime utcDateTime;

  MatchEntity({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeLogo,
    required this.awayLogo,
    this.homeGoals,
    this.awayGoals,
    required this.status,
    required this.stadium,
    required this.stage,
    this.group,
    required this.utcDateTime,
  });
}
2. Fuente de Datos Remota (Data Layer)
Dart
// lib/features/matches_board/data/datasources/matches_remote_datasource.dart
import 'package:dio/dio.dart';
import '../../domain/entities/match_entity.dart';

class MatchesRemoteDataSource {
  final Dio dio;

  MatchesRemoteDataSource(this.dio);

  Future<List<MatchEntity>> getMatchesByDate(String dateStr) async {
    try {
      final response = await dio.get('/fixtures', queryParameters: {
        'league': '1', // Código oficial de la Copa del Mundo FIFA
        'season': '2026',
        'date': dateStr, 
      });

      final List data = response.data['response'] ?? [];
      
      return data.map((item) {
        final fixture = item['fixture'];
        final teams = item['teams'];
        final goals = item['goals'];

        return MatchEntity(
          id: fixture['id'].toString(),
          homeTeam: teams['home']['name'],
          awayTeam: teams['away']['name'],
          homeLogo: teams['home']['logo'],
          awayLogo: teams['away']['logo'],
          homeGoals: goals['home'],
          awayGoals: goals['away'],
          status: fixture['status']['short'],
          stadium: fixture['venue']['name'] ?? 'Estadio por definir',
          stage: fixture['league']['round'] ?? 'Fase de Grupos',
          group: item['league']['round'].toString().contains('Group') 
              ? item['league']['round'] 
              : null,
          utcDateTime: DateTime.parse(fixture['date']),
        );
      }).toList();
    } on DioException catch (e) {
      throw Exception('Error de red: ${e.type} - ${e.message}');
    } catch (e) {
      throw Exception('Error al procesar los datos del servidor.');
    }
  }
}
3. Pantalla de Inicio (Presentation Layer con FutureBuilder)
Maneja estrictamente los estados asíncronos y las restricciones temporales del calendario (11 de Junio al 19 de Julio de 2026).

Dart
// lib/features/matches_board/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/matches_remote_datasource.dart';
import '../../domain/entities/match_entity.dart';
import '../../../match_detail/presentation/screens/detail_screen.dart';
import '../../../../core/theme/world_cup_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late MatchesRemoteDataSource _dataSource;
  late Future<List<MatchEntity>> _matchesFuture;
  DateTime _selectedDate = DateTime.now();

  final DateTime _worldCupStart = DateTime(2026, 6, 11);
  final DateTime _worldCupEnd = DateTime(2026, 7, 19);

  @override
  void initState() {
    super.initState();
    _dataSource = MatchesRemoteDataSource(DioClient().dio);
    
    // Forzar fecha dentro del mundial si el sistema está fuera de rango
    if (DateTime.now().isBefore(_worldCupStart) || DateTime.now().isAfter(_worldCupEnd)) {
      _selectedDate = _worldCupStart;
    }
    _loadMatches();
  }

  void _loadMatches() {
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    setState(() {
      _matchesFuture = _dataSource.getMatchesByDate(formattedDate);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: _worldCupStart,
      lastDate: _worldCupEnd,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: WorldCupColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: WorldCupColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadMatches();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WorldCupColors.background,
      appBar: AppBar(
        title: const Text('FIFA World Cup 2026 ⚽', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: WorldCupColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_rounded),
            onPressed: () => _selectDate(context),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
            color: WorldCupColors.cardBackground,
            width: double.infinity,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
            ],
            child: Text(
              'Partidos: ${DateFormat('EEEE, dd \'de\' MMMM', 'es').format(_selectedDate).toUpperCase()}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: WorldCupColors.vibrantPurple, letterSpacing: 0.5),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<MatchEntity>>(
              future: _matchesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(WorldCupColors.vibrantPurple)));
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Text(
                        'Error de Diagnóstico:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: WorldCupColors.vibrantRed, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                }

                final matches = snapshot.data ?? [];

                if (matches.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay partidos del Mundial en esta fecha',
                      style: TextStyle(fontSize: 16, color: WorldCupColors.textMuted, fontWeight: FontWeight.w500),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: WorldCupColors.cardBackground,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 1.5,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DetailScreen(match: match)),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(match.homeTeam, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: WorldCupColors.textDark)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    margin: const EdgeInsets.symmetric(horizontal: 14),
                                    decoration: BoxDecoration(
                                      color: match.homeGoals != null ? WorldCupColors.deepGreen.withOpacity(0.1) : WorldCupColors.background,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      match.homeGoals != null ? '${match.homeGoals} - ${match.awayGoals}' : 'VS',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: match.homeGoals != null ? WorldCupColors.vibrantGreen : WorldCupColors.textMuted,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(match.awayTeam, textAlign: TextAlign.start, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: WorldCupColors.textDark)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${match.stage} • ${match.stadium}',
                                style: const TextStyle(fontSize: 12, color: WorldCupColors.textMuted, fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
🔍 Vertical Slice: Match Detail (HU-03)
Pantalla de Detalle Estilizada
Incluye transformación horaria a formato local del dispositivo móvil y ocultamiento condicional y seguro de campos vacíos para fases eliminatorias.

Dart
// lib/features/match_detail/presentation/screens/detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../matches_board/domain/entities/match_entity.dart';
import '../../../../core/theme/world_cup_colors.dart';

class DetailScreen extends StatelessWidget {
  final MatchEntity match;

  const DetailScreen({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final localTime = match.utcDateTime.toLocal();
    final formattedLocalTime = DateFormat('dd/MM/yyyy - HH:mm \'hs\'').format(localTime);

    return Scaffold(
      backgroundColor: WorldCupColors.cardBackground,
      appBar: AppBar(
        title: const Text('Detalle del Partido'),
        backgroundColor: WorldCupColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: WorldCupColors.hotPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                match.stage.toUpperCase(),
                style: const TextStyle(color: WorldCupColors.hotPink, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.1),
              ),
            ),
            const SizedBox(height: 32),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      ClipOval(
                        child: Image.network(match.homeLogo, width: 72, height: 72, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.flag_rounded, size: 72, color: WorldCupColors.textMuted)),
                      ),
                      const SizedBox(height: 12),
                      Text(match.homeTeam, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: WorldCupColors.textDark)),
                    ],
                  ),
                ),
                Text(
                  match.homeGoals != null ? '${match.homeGoals} : ${match.awayGoals}' : 'VS',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: WorldCupColors.primaryBlue, letterSpacing: -1),
                ),
                Expanded(
                  child: Column(
                    children: [
                      ClipOval(
                        child: Image.network(match.awayLogo, width: 72, height: 72, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.flag_rounded, size: 72, color: WorldCupColors.textMuted)),
                      ),
                      const SizedBox(height: 12),
                      Text(match.awayTeam, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: WorldCupColors.textDark)),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            const Divider(color: WorldCupColors.background, thickness: 2),
            const SizedBox(height: 24),
            
            Container(
              decoration: BoxDecoration(
                color: WorldCupColors.background,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.stadium_rounded, color: WorldCupColors.deepGreen)),
                    title: const Text('Estadio / Sede', style: TextStyle(fontSize: 13, color: WorldCupColors.textMuted, fontWeight: FontWeight.w500)),
                    subtitle: Text(match.stadium, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: WorldCupColors.textDark)),
                  ),
                  ListTile(
                    leading: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.watch_later_rounded, color: WorldCupColors.vibrantPurple)),
                    title: const Text('Horario Local (Tu Dispositivo)', style: TextStyle(fontSize: 13, color: WorldCupColors.textMuted, fontWeight: FontWeight.w500)),
                    subtitle: Text(formattedLocalTime, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: WorldCupColors.textDark)),
                  ),
                  if (match.group != null)
                    ListTile(
                      leading: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.grid_view_rounded, color: WorldCupColors.brightCyan)),
                      title: const Text('Clasificación', style: TextStyle(fontSize: 13, color: WorldCupColors.textMuted, fontWeight: FontWeight.w500)),
                      subtitle: Text(match.group!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: WorldCupColors.textDark)),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}