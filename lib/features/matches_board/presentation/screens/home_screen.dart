import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/matches_remote_datasource.dart';
import '../../data/repositories/matches_repository_impl.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/repositories/matches_repository.dart';
import '../widgets/date_selector_bar.dart';
import '../widgets/match_card_widget.dart';
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
            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: WorldCupColors.cardBackground,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
              ],
            ),
            width: double.infinity,
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
