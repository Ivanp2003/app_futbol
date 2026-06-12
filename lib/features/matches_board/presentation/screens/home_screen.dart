import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/matches_remote_datasource.dart';
import '../../data/repositories/matches_repository_impl.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/repositories/matches_repository.dart';
import '../widgets/date_selector_bar.dart';
import '../widgets/match_card_widget.dart';
import 'filter_screen.dart';
import '../../../../core/theme/world_cup_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late MatchesRepository _repository;
  late Future<List<MatchEntity>> _matchesFuture;
  DateTime _selectedDate = DateTime.now();

  String _statusFilter = 'Todos';
  String _stageFilter = 'Todos';

  final DateTime _worldCupStart = DateTime(2026, 6, 11);
  final DateTime _worldCupEnd = DateTime(2026, 7, 19);

  @override
  void initState() {
    super.initState();
    final dio = DioClient().dio;
    final dataSource = MatchesRemoteDataSource(dio);
    _repository = MatchesRepositoryImpl(dataSource);
    
    // Forzar fecha dentro del mundial si el sistema está fuera de rango
    if (DateTime.now().isBefore(_worldCupStart) || DateTime.now().isAfter(_worldCupEnd)) {
      _selectedDate = _worldCupStart;
    }
    _loadMatches();
  }

  void _loadMatches() {
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    setState(() {
      _matchesFuture = _repository.getMatches(formattedDate);
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
              primary: WorldCupColors.magenta,
              onPrimary: Colors.white,
              onSurface: WorldCupColors.dark,
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
      backgroundColor: WorldCupColors.bg,
      appBar: AppBar(
        title: const Text('Mundial 2026 ⚽', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: WorldCupColors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FilterScreen(
                    currentStatusFilter: _statusFilter,
                    currentStageFilter: _stageFilter,
                  ),
                ),
              );
              if (result != null && result is Map<String, String>) {
                setState(() {
                  _statusFilter = result['status'] ?? 'Todos';
                  _stageFilter = result['stage'] ?? 'Todos';
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today_rounded),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          DateSelectorBar(
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
              _loadMatches();
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, dd \'de\' MMMM', 'es').format(_selectedDate).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: WorldCupColors.magenta,
                    letterSpacing: 0.5,
                  ),
                ),
                if (_statusFilter != 'Todos' || _stageFilter != 'Todos')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: WorldCupColors.magenta.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'FILTRADO',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: WorldCupColors.magenta,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<MatchEntity>>(
              future: _matchesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(WorldCupColors.magenta),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Text(
                        'Error al cargar partidos:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: WorldCupColors.magenta,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }

                final allMatches = snapshot.data ?? [];

                // Aplicar filtros locales de presentación
                final matches = allMatches.where((match) {
                  // Filtrar por estado
                  if (_statusFilter == 'En Vivo' && !match.isLive) return false;
                  if (_statusFilter == 'Finalizados') {
                    final finished = match.status == 'FINISHED' || match.status == 'FT';
                    if (!finished) return false;
                  }
                  if (_statusFilter == 'Programados') {
                    final scheduled = match.status != 'FINISHED' && match.status != 'FT' && !match.isLive;
                    if (!scheduled) return false;
                  }

                  // Filtrar por competición
                  final stageLower = match.stage.toLowerCase();
                  if (_stageFilter == 'Copa del Mundo FIFA') {
                    final isWorldCup = stageLower.contains('world cup') || stageLower.contains('copa del mundo') || stageLower.contains('mundial');
                    if (!isWorldCup) return false;
                  }
                  if (_stageFilter == 'Major League Soccer') {
                    final isMLS = stageLower.contains('mls') || stageLower.contains('major league');
                    if (!isMLS) return false;
                  }

                  return true;
                }).toList();

                if (matches.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay partidos para los filtros seleccionados',
                      style: TextStyle(
                        fontSize: 14,
                        color: WorldCupColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    return MatchCardWidget(match: match);
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
