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
  final bool isLive;
  final int? minute;

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
    this.isLive = false,
    this.minute,
  });
}