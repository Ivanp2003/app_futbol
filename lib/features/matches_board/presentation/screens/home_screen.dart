import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/world_cup_dates.dart';
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

  final DateTime _worldCupStart = WorldCupDates.start;
  final DateTime _worldCupEnd = WorldCupDates.end;

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
              primary: WorldCupColors.accent,
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: _FifaHeaderBanner(
          onFilter: () async {
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
          onCalendar: () => _selectDate(context),
        ),
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
                    color: WorldCupColors.accent,
                    letterSpacing: 0.5,
                  ),
                ),
                if (_statusFilter != 'Todos' || _stageFilter != 'Todos')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: WorldCupColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'FILTRADO',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: WorldCupColors.accent,
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
                      valueColor: AlwaysStoppedAnimation<Color>(WorldCupColors.accent),
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
                          color: WorldCupColors.live,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }

                final allMatches = snapshot.data ?? [];

                // Escenario 2 HU-01: la API respondió vacío para esta fecha
                if (allMatches.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay partidos del Mundial en esta fecha',
                      style: TextStyle(
                        fontSize: 14,
                        color: WorldCupColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

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

                // Filtros activos pero sin resultados
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

// ─────────────────────────────────────────────────────────
// Header FIFA-style: rojo dominante · cuña azul diagonal · franja verde
// ─────────────────────────────────────────────────────────

class _FifaHeaderBanner extends StatelessWidget {
  final VoidCallback onFilter;
  final VoidCallback onCalendar;

  const _FifaHeaderBanner({
    required this.onFilter,
    required this.onCalendar,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final totalHeight = 56.0 + topPadding;

    return SizedBox(
      height: totalHeight,
      child: CustomPaint(
        painter: _HeaderPainter(),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                const SizedBox(width: 16),
                // Título
                const Expanded(
                  child: Text(
                    'MUNDIAL 2026',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                // Acciones
                IconButton(
                  icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
                  onPressed: onFilter,
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today_rounded, color: Colors.white),
                  onPressed: onCalendar,
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dibuja la composición geométrica FIFA:
///   - Fondo rojo (#E53935) que cubre ~85% del ancho
///   - Cuña azul (#0066CC) entrando desde la derecha con corte diagonal a 60°
///   - Franja verde (#00A651) de 4 px en el borde inferior
class _HeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const stripeH = 8.0;

    // 1. Fondo rojo completo
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFE53935),
    );

    // 2. Cuña azul: trapecio en el lado derecho con corte diagonal a ~60°
    //    El corte empieza en el 62% del ancho (arriba) y el 78% (abajo)
    final diagonalOffset = h * 0.6; // profundidad horizontal del ángulo
    final blueStart = w * 0.62;

    final bluePath = Path()
      ..moveTo(blueStart, 0)           // punto superior del corte
      ..lineTo(w, 0)                   // esquina superior derecha
      ..lineTo(w, h - stripeH)         // esquina inferior derecha
      ..lineTo(blueStart + diagonalOffset, h - stripeH) // punto inferior del corte
      ..close();

    canvas.drawPath(
      bluePath,
      Paint()..color = const Color(0xFF0066CC),
    );

    // 3. Franja verde en el borde inferior (sobre todo lo anterior)
    canvas.drawRect(
      Rect.fromLTWH(0, h - stripeH, w, stripeH),
      Paint()..color = const Color(0xFF00A651),
    );
  }

  @override
  bool shouldRepaint(_HeaderPainter oldDelegate) => false;
}
