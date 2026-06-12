import '../../domain/entities/match_entity.dart';

class MatchModel extends MatchEntity {
  MatchModel({
    required super.id,
    required super.homeTeam,
    required super.awayTeam,
    required super.homeLogo,
    required super.awayLogo,
    super.homeGoals,
    super.awayGoals,
    required super.status,
    required super.stadium,
    required super.stage,
    super.group,
    required super.utcDateTime,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    final fixture = json['fixture'] as Map<String, dynamic>;
    final teams = json['teams'] as Map<String, dynamic>;
    final goals = json['goals'] as Map<String, dynamic>;
    final league = json['league'] as Map<String, dynamic>?;

    final round = league?['round']?.toString();
    final groupName = (round != null && round.contains('Group')) ? round : null;

    return MatchModel(
      id: fixture['id'].toString(),
      homeTeam: teams['home']['name'] as String? ?? '',
      awayTeam: teams['away']['name'] as String? ?? '',
      homeLogo: teams['home']['logo'] as String? ?? '',
      awayLogo: teams['away']['logo'] as String? ?? '',
      homeGoals: goals['home'] as int?,
      awayGoals: goals['away'] as int?,
      status: fixture['status']['short'] as String? ?? '',
      stadium: fixture['venue']?['name'] as String? ?? 'Estadio por definir',
      stage: league?['round'] as String? ?? 'Fase de Grupos',
      group: groupName,
      utcDateTime: DateTime.parse(fixture['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fixture': {
        'id': id,
        'status': {'short': status},
        'venue': {'name': stadium},
        'date': utcDateTime.toIso8601String(),
      },
      'teams': {
        'home': {'name': homeTeam, 'logo': homeLogo},
        'away': {'name': awayTeam, 'logo': awayLogo},
      },
      'goals': {
        'home': homeGoals,
        'away': awayGoals,
      },
      'league': {
        'round': stage,
      }
    };
  }
}
