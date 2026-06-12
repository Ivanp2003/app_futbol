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
                    child: Text(
                      match.homeTeam,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: WorldCupColors.textDark,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    margin: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: match.homeGoals != null
                          ? WorldCupColors.deepGreen.withValues(alpha: 0.1)
                          : WorldCupColors.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      match.homeGoals != null
                          ? '${match.homeGoals} - ${match.awayGoals}'
                          : 'VS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: match.homeGoals != null
                            ? WorldCupColors.vibrantGreen
                            : WorldCupColors.textMuted,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      match.awayTeam,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: WorldCupColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${match.stage} • ${match.stadium}',
                style: const TextStyle(
                  fontSize: 12,
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
