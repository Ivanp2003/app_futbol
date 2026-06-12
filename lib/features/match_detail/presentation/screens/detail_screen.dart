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
                color: WorldCupColors.hotPink.withValues(alpha: 0.1),
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
                        child: match.homeLogo.isNotEmpty
                            ? Image.network(
                                match.homeLogo,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.flag_rounded,
                                  size: 72,
                                  color: WorldCupColors.textMuted,
                                ),
                              )
                            : const Icon(
                                Icons.flag_rounded,
                                size: 72,
                                color: WorldCupColors.textMuted,
                              ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        match.homeTeam,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: WorldCupColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  match.homeGoals != null ? '${match.homeGoals} : ${match.awayGoals}' : 'VS',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: WorldCupColors.primaryBlue,
                    letterSpacing: -1,
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      ClipOval(
                        child: match.awayLogo.isNotEmpty
                            ? Image.network(
                                match.awayLogo,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.flag_rounded,
                                  size: 72,
                                  color: WorldCupColors.textMuted,
                                ),
                              )
                            : const Icon(
                                Icons.flag_rounded,
                                size: 72,
                                color: WorldCupColors.textMuted,
                              ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        match.awayTeam,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: WorldCupColors.textDark,
                        ),
                      ),
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
                    leading: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.stadium_rounded, color: WorldCupColors.deepGreen),
                    ),
                    title: const Text(
                      'Estadio / Sede',
                      style: TextStyle(fontSize: 13, color: WorldCupColors.textMuted, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      match.stadium,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: WorldCupColors.textDark),
                    ),
                  ),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.watch_later_rounded, color: WorldCupColors.vibrantPurple),
                    ),
                    title: const Text(
                      'Horario Local (Tu Dispositivo)',
                      style: TextStyle(fontSize: 13, color: WorldCupColors.textMuted, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      formattedLocalTime,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: WorldCupColors.textDark),
                    ),
                  ),
                  if (match.group != null)
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.grid_view_rounded, color: WorldCupColors.brightCyan),
                      ),
                      title: const Text(
                        'Clasificación',
                        style: TextStyle(fontSize: 13, color: WorldCupColors.textMuted, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        match.group!,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: WorldCupColors.textDark),
                      ),
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
