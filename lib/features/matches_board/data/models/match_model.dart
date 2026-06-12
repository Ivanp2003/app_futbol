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
    super.isLive = false,
    super.minute,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    final homeTeam = json['homeTeam'] as Map<String, dynamic>? ?? {};
    final awayTeam = json['awayTeam'] as Map<String, dynamic>? ?? {};
    final score = json['score']?['fullTime'] as Map<String, dynamic>? ?? {};
    final competition = json['competition'] as Map<String, dynamic>? ?? {};
    
    final currentStatus = json['status'] as String? ?? 'NS';
    final liveActive = currentStatus == 'LIVE' || currentStatus == 'IN_PLAY';
    final minute = json['minute'] as int?;

    return MatchModel(
      id: json['id'].toString(),
      homeTeam: homeTeam['name'] as String? ?? 'Local',
      awayTeam: awayTeam['name'] as String? ?? 'Visitante',
      homeLogo: homeTeam['crest'] as String? ?? '',
      awayLogo: awayTeam['crest'] as String? ?? '',
      homeGoals: score['home'] as int?,
      awayGoals: score['away'] as int?,
      status: currentStatus,
      stadium: json['venue'] as String? ?? 'Estadio por definir',
      stage: competition['name'] as String? ?? 'Fase de Grupos',
      group: json['group'] as String?,
      utcDateTime: DateTime.parse(json['utcDate'] as String),
      isLive: liveActive,
      minute: minute,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'venue': stadium,
      'utcDate': utcDateTime.toIso8601String(),
      'homeTeam': {'name': homeTeam, 'crest': homeLogo},
      'awayTeam': {'name': awayTeam, 'crest': awayLogo},
      'score': {
        'fullTime': {'home': homeGoals, 'away': awayGoals}
      },
      'competition': {'name': stage},
      'group': group,
      'isLive': isLive,
      'minute': minute,
    };
  }
}
