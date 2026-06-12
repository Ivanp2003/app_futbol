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

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: WorldCupColors.bg,
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 220.0,
                floating: false,
                pinned: true,
                backgroundColor: WorldCupColors.blue,
                foregroundColor: Colors.white,
                elevation: 0,
                title: Text(
                  match.stage,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [WorldCupColors.blue, Color(0xFF0D256B)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 80, left: 16, right: 16, bottom: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Local Team Info
                            Expanded(
                              child: Column(
                                children: [
                                  ClipOval(
                                    child: match.homeLogo.isNotEmpty
                                        ? Image.network(
                                            match.homeLogo,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => const Icon(
                                              Icons.flag_rounded,
                                              size: 50,
                                              color: Colors.white70,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.flag_rounded,
                                            size: 50,
                                            color: Colors.white70,
                                          ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    match.homeTeam,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // Score or Status
                            Column(
                              children: [
                                Text(
                                  match.homeGoals != null
                                      ? '${match.homeGoals} - ${match.awayGoals}'
                                      : 'VS',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (match.isLive)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: WorldCupColors.magenta,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${match.minute ?? 0}\'',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                else
                                  Text(
                                    match.status == 'FINISHED' || match.status == 'FT'
                                        ? 'Finalizado'
                                        : 'Programado',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),

                            // Away Team Info
                            Expanded(
                              child: Column(
                                children: [
                                  ClipOval(
                                    child: match.awayLogo.isNotEmpty
                                        ? Image.network(
                                            match.awayLogo,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => const Icon(
                                              Icons.flag_rounded,
                                              size: 50,
                                              color: Colors.white70,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.flag_rounded,
                                            size: 50,
                                            color: Colors.white70,
                                          ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    match.awayTeam,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    labelColor: WorldCupColors.magenta,
                    unselectedLabelColor: WorldCupColors.gray,
                    indicatorColor: WorldCupColors.magenta,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: const [
                      Tab(text: 'Resumen'),
                      Tab(text: 'Alineaciones'),
                      Tab(text: 'Estadísticas'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildResumenTab(formattedLocalTime),
              _buildAlineacionesTab(),
              _buildEstadisticasTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResumenTab(String formattedLocalTime) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Card
          Card(
            color: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: WorldCupColors.lightGray,
                      child: Icon(Icons.stadium_rounded, color: WorldCupColors.green),
                    ),
                    title: const Text('Estadio / Sede', style: TextStyle(fontSize: 12, color: WorldCupColors.gray)),
                    subtitle: Text(match.stadium, style: const TextStyle(fontWeight: FontWeight.bold, color: WorldCupColors.dark)),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: WorldCupColors.lightGray,
                      child: Icon(Icons.watch_later_rounded, color: WorldCupColors.blue),
                    ),
                    title: const Text('Horario Local', style: TextStyle(fontSize: 12, color: WorldCupColors.gray)),
                    subtitle: Text(formattedLocalTime, style: const TextStyle(fontWeight: FontWeight.bold, color: WorldCupColors.dark)),
                  ),
                  if (match.group != null) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: WorldCupColors.lightGray,
                        child: Icon(Icons.grid_view_rounded, color: WorldCupColors.magenta),
                      ),
                      title: const Text('Clasificación', style: TextStyle(fontSize: 12, color: WorldCupColors.gray)),
                      subtitle: Text(match.group!, style: const TextStyle(fontWeight: FontWeight.bold, color: WorldCupColors.dark)),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Possession Section (Highlight UI requirement)
          const Text(
            'Posesión del Balón',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: WorldCupColors.dark),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${match.homeTeam} (58%)',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: WorldCupColors.magenta),
                      ),
                      Text(
                        '(42%) ${match.awayTeam}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: WorldCupColors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress indicator combining Home (Magenta) and Away (Green)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      height: 12,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 58,
                            child: Container(color: WorldCupColors.magenta),
                          ),
                          Expanded(
                            flex: 42,
                            child: Container(color: WorldCupColors.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlineacionesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Formación Inicial (4-3-3)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: WorldCupColors.dark),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildLineupRow(match.homeTeam, 'Entrenador A', ['P. López (GK)', 'M. Sedeño (DF)', 'J. Gómez (DF)', 'A. Rueda (DF)', 'F. Silva (DF)', 'C. Ortiz (MC)', 'D. Marín (MC)', 'J. Rangel (MC)', 'S. Castro (FW)', 'K. Benzema (FW)', 'E. Hazard (FW)']),
                  const Divider(height: 32),
                  _buildLineupRow(match.awayTeam, 'Entrenador B', ['A. Becker (GK)', 'D. Alves (DF)', 'Marquinhos (DF)', 'T. Silva (DF)', 'Marcelo (DF)', 'Casemiro (MC)', 'Fred (MC)', 'Paquetá (MC)', 'Neymar Jr (FW)', 'Richarlison (FW)', 'Vinicius Jr (FW)']),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineupRow(String teamName, String coach, List<String> players) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(teamName, style: const TextStyle(fontWeight: FontWeight.bold, color: WorldCupColors.blue, fontSize: 15)),
        Text('DT: $coach', style: const TextStyle(color: WorldCupColors.gray, fontSize: 12)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: players.map((player) {
            return Chip(
              backgroundColor: WorldCupColors.lightGray,
              label: Text(player, style: const TextStyle(fontSize: 11, color: WorldCupColors.dark)),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEstadisticasTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estadísticas del Partido',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: WorldCupColors.dark),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildStatRow('Disparos Totales', '12', '8'),
                  _buildStatRow('Disparos al Arco', '5', '3'),
                  _buildStatRow('Faltas Cometidas', '10', '12'),
                  _buildStatRow('Tiros de Esquina', '6', '4'),
                  _buildStatRow('Fueras de Juego', '2', '1'),
                  _buildStatRow('Tarjetas Amarillas', '1', '2'),
                  _buildStatRow('Tarjetas Rojas', '0', '0'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String homeValue, String awayValue) {
    final homeInt = int.tryParse(homeValue) ?? 0;
    final awayInt = int.tryParse(awayValue) ?? 0;
    final total = homeInt + awayInt;
    final homePercent = total > 0 ? homeInt / total : 0.5;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(homeValue, style: const TextStyle(fontWeight: FontWeight.bold, color: WorldCupColors.magenta)),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: WorldCupColors.dark)),
              Text(awayValue, style: const TextStyle(fontWeight: FontWeight.bold, color: WorldCupColors.green)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: Row(
                children: [
                  Expanded(
                    flex: (homePercent * 100).round(),
                    child: Container(color: WorldCupColors.magenta.withValues(alpha: 0.8)),
                  ),
                  Expanded(
                    flex: ((1 - homePercent) * 100).round(),
                    child: Container(color: WorldCupColors.green.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
