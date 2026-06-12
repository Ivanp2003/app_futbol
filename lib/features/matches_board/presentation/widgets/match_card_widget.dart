import 'package:flutter/material.dart';
import '../../domain/entities/match_entity.dart';
import '../../../match_detail/presentation/screens/detail_screen.dart';
import '../../../../core/theme/world_cup_colors.dart';

class MatchCardWidget extends StatelessWidget {
  final MatchEntity match;

  const MatchCardWidget({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      color: WorldCupColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DetailScreen(match: match)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (match.isLive) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: WorldCupColors.magenta.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.circle, size: 8, color: WorldCupColors.magenta),
                          const SizedBox(width: 6),
                          Text(
                            '● EN VIVO ${match.minute != null ? "${match.minute}'" : ""}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: WorldCupColors.magenta,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  // Equipo Local + Logo
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            match.homeTeam,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 14, 
                              color: WorldCupColors.textDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ClipOval(
                          child: match.homeLogo.isNotEmpty
                              ? Image.network(
                                  match.homeLogo,
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.flag_rounded,
                                    color: WorldCupColors.textMuted,
                                  ),
                                )
                              : const Icon(
                                  Icons.flag_rounded,
                                  color: WorldCupColors.textMuted,
                                ),
                        ),
                      ],
                    ),
                  ),

                  // Marcador / VS Central
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: match.homeGoals != null
                          ? WorldCupColors.green.withValues(alpha: 0.1)
                          : WorldCupColors.lightGray,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      match.homeGoals != null ? '${match.homeGoals} - ${match.awayGoals}' : 'VS',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: match.homeGoals != null ? WorldCupColors.green : WorldCupColors.textMuted,
                      ),
                    ),
                  ),

                  // Equipo Visitante + Logo
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ClipOval(
                          child: match.awayLogo.isNotEmpty
                              ? Image.network(
                                  match.awayLogo,
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.flag_rounded,
                                    color: WorldCupColors.textMuted,
                                  ),
                                )
                              : const Icon(
                                  Icons.flag_rounded,
                                  color: WorldCupColors.textMuted,
                                ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            match.awayTeam,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: WorldCupColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Detalles de la Sede con tipografía oficial mitigada
              Text(
                '${match.stage} • ${match.stadium}',
                style: const TextStyle(
                  fontSize: 11,
                  color: WorldCupColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
