import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:inclusive_app/core/constants/api_constants.dart';
import 'package:inclusive_app/core/errors/exceptions.dart';
import 'package:inclusive_app/features/profile/data/models/user_evaluation_model.dart';

/// Fuente de datos remota para las evaluaciones del usuario
abstract class UserEvaluationRemoteDataSource {
  /// Obtiene todas las evaluaciones del usuario desde el backend
  Future<List<UserEvaluationModel>> getUserEvaluations(String userId);
}

/// Implementación de [UserEvaluationRemoteDataSource] usando HTTP client
class UserEvaluationRemoteDataSourceImpl
    implements UserEvaluationRemoteDataSource {
  final http.Client client;
  final Future<String> Function() getToken;

  const UserEvaluationRemoteDataSourceImpl({
    required this.client,
    required this.getToken,
  });

  @override
  Future<List<UserEvaluationModel>> getUserEvaluations(String userId) async {
    final token = await getToken();
    developer.log('🔍 Buscando evaluaciones para userId: $userId', name: 'UserEvaluations');
    developer.log('🔑 Token del usuario: $token', name: 'UserEvaluations');
    
    final response = await client.get(
      Uri.parse(ApiConstants.userEvaluations),
      headers: {...ApiConstants.authHeaders(token)},
    );

    developer.log('📡 Response status: ${response.statusCode}', name: 'UserEvaluations');

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      developer.log('📦 Response body: $responseBody', name: 'UserEvaluations');
      
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);
      final List dataList = jsonResponse['data'] as List;

      developer.log('📋 Total places en respuesta: ${dataList.length}', name: 'UserEvaluations');

      // Filtrar solo las evaluaciones donde el usuario actual ha participado
      final evaluations = dataList
          .map(
            (json) => UserEvaluationModel.fromJson(
              json as Map<String, dynamic>,
              userId,
            ),
          )
          .where((evaluation) => evaluation.rateChoice != 'UNKNOWN')
          .toList();
      
      developer.log('✅ Evaluaciones filtradas para usuario: ${evaluations.length}', name: 'UserEvaluations');
      for (var e in evaluations) {
        developer.log('  - PlaceId: ${e.placeId}, RateChoice: ${e.rateChoice}', name: 'UserEvaluations');
      }
      
      return evaluations;
    } else {
      developer.log('❌ Error: ${response.statusCode} - ${response.body}', name: 'UserEvaluations');
      throw ServerException('Error al obtener las evaluaciones del usuario');
    }
  }
}
