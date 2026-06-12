class MatchDetailEntity {
  final String id;
  final String homeTeamName;
  final String awayTeamName;
  final int homeTeamScore;
  final int awayTeamScore;
  final DateTime utcDate;
  final String status;
  final String stadium;
  final String referee;
  final List<MatchEventEntity> events;

  const MatchDetailEntity({
    required this.id,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.homeTeamScore,
    required this.awayTeamScore,
    required this.utcDate,
    required this.status,
    required this.stadium,
    required this.referee,
    required this.events,
  });
}

class MatchEventEntity {
  final String type; // GOAL, CARD, SUB
  final int minute;
  final String detail;
  final String teamName;

  const MatchEventEntity({
    required this.type,
    required this.minute,
    required this.detail,
    required this.teamName,
  });
}
