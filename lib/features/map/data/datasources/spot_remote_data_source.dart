import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inclusivecity_frontend/constants/api_constants.dart';
import 'package:inclusivecity_frontend/core/error/exception/exceptions.dart';
import 'package:inclusivecity_frontend/features/map/data/models/spot_model.dart';

abstract class SpotRemoteDataSource {
  /// Guarda un spot del usuario
  /// Throws [ServerException] si falla
  Future<SpotModel> saveSpot(SpotModel spot);

  /// Obtiene todos los spots de un usuario
  /// Throws [ServerException] si falla
  Future<List<SpotModel>> getUserSpots(String userId);
}

class SpotRemoteDataSourceImpl implements SpotRemoteDataSource {
  final http.Client client;

  SpotRemoteDataSourceImpl({required this.client});

  @override
  Future<SpotModel> saveSpot(SpotModel spot) async {
    try {
      final response = await client.post(
        Uri.parse(ApiConstants.createSpot),
        headers: ApiConstants.jsonHeaders,
        body: json.encode(spot.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        // El backend devuelve {data: {...}}
        final data = jsonResponse['data'];
        return SpotModel.fromJson(data);
      } else {
        throw ServerException(
          'Error al guardar spot: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw ServerException('Error al guardar spot: $e');
    }
  }

  @override
  Future<List<SpotModel>> getUserSpots(String userId) async {
    try {
      final response = await client.get(
        Uri.parse(ApiConstants.userSpots(userId)),
        headers: ApiConstants.jsonHeaders,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        // El backend devuelve {data: [...]}
        final data = jsonResponse['data'] as List;
        return data.map((json) => SpotModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          'Error al obtener spots: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw ServerException('Error al obtener spots: $e');
    }
  }
}
