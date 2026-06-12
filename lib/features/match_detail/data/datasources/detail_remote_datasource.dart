import 'package:dio/dio.dart';
import '../../../matches_board/data/models/match_model.dart';

class DetailRemoteDataSource {
  final Dio dio;

  DetailRemoteDataSource({required this.dio});

  Future<MatchModel?> getMatchDetail(String matchId) async {
    try {
      final response = await dio.get('/matches/$matchId');
      if (response.statusCode == 200) {
        return MatchModel.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
