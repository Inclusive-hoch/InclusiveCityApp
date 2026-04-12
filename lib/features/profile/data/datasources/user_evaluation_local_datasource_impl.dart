import 'dart:convert';
import 'package:inclusive_app/features/profile/data/models/user_evaluation_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inclusive_app/features/profile/data/datasources/user_evaluation_local_datasource.dart';
import 'package:inclusive_app/features/profile/domain/entities/user_evaluation.dart';

class UserEvaluationLocalDatasourceImpl implements UserEvaluationLocalDatasource{
  final SharedPreferences sharedPreferences;

  UserEvaluationLocalDatasourceImpl({required this.sharedPreferences});
  //funciones que crean claves unicas por usuario
  String _getCacheKey(String userId) => 'CACHED_EVALUATIONS_$userId';
  String _getTimeKey(String userId) => 'CACHED_EVALUATIONS_TIME_$userId';

  @override
  Future<List<UserEvaluation>> getCachedEvaluations(String userId) async {
    final jsonString = sharedPreferences.getString(_getCacheKey(userId));

    if(jsonString != null){
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json)=> UserEvaluationModel.fromJson(json, userId)).toList();
    }

    return [];
  }

  @override
  Future<void> cacheEvaluations(String userId, List<UserEvaluation> evaluations) async {
    // transforma la lista de evaluaciones en json
    final List<Map<String, dynamic>> jsonList = evaluations.map((e) {
      if (e is UserEvaluationModel) {
        return e.toJson();
      }

      return {
        'placeId': e.placeId,
        'medals': e.medals,
        'rating': e.rating,
        'rateChoice': e.rateChoice,
        'forms': e.forms,
      };
    }).toList();

    //guardar la lista json en sharedprederences
    await sharedPreferences.setString(_getCacheKey(userId), jsonEncode(jsonList));

    //guardar hora actual como texto
    await sharedPreferences.setString(_getTimeKey(userId), DateTime.now().toIso8601String());
  }

  @override
  Future<DateTime?> getLastUpdate(String userId) async {
    final timeString = sharedPreferences.getString(_getTimeKey(userId));

    if(timeString != null){
      return DateTime.parse(timeString);
    }
    
    return null;
  }
}