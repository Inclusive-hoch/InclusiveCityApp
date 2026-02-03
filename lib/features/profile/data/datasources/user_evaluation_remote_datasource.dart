import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inclusive_app/core/constants/api_constants.dart';
import 'package:inclusive_app/core/errors/exceptions.dart';
import 'package:inclusive_app/features/profile/data/models/user_evaluation_model.dart';

/// Fuente de datos remota para las evaluaciones del usuario
abstract class UserEvaluationRemoteDataSource {
  /// Obtiene todas las evaluaciones del usuario desde el backend
  Future<List<UserEvaluationModel>> getUserEvaluations();
}

/// Implementación de [UserEvaluationRemoteDataSource] usando HTTP client
class UserEvaluationRemoteDataSourceImpl implements UserEvaluationRemoteDataSource {
  final http.Client client;
  final String Function() getToken;

  const UserEvaluationRemoteDataSourceImpl({
    required this.client,
    required this.getToken,
  });

  @override
  Future<List<UserEvaluationModel>> getUserEvaluations() async {
    final token = getToken();
    final response = await client.get(
      Uri.parse(ApiConstants.userEvaluations),
      headers: {...ApiConstants.authHeaders(token)},
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);
      final List dataList = jsonResponse['data'] as List;

      return dataList
          .map((json) => UserEvaluationModel.fromJson(json))
          .toList();
    } else {
      throw ServerException('Error al obtener las evaluaciones del usuario');
    }
  }
}