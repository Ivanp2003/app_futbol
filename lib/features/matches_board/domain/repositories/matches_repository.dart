import '../entities/match_entity.dart';

abstract class MatchesRepository {
  Future<List<MatchEntity>> getMatches(String dateStr);
}
