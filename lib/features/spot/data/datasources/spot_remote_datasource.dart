import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inclusive_app/core/constants/api_constants.dart';
import 'package:inclusive_app/core/errors/exceptions.dart';
import 'package:inclusive_app/features/spot/data/models/custom_spot_model.dart';
import 'package:inclusive_app/features/spot/data/models/spot_model.dart';

/// Fuente de datos remota para gestión de spots y listas personalizadas.
abstract class SpotRemoteDatasource {
  /// Crea un nuevo spot en el backend.
  Future<SpotModel> createSpot(SpotModel spot);

  /// Obtiene los spots del usuario autenticado.
  Future<List<SpotModel>> getUserSpots();

  /// Elimina un spot por su ubicación.
  Future<int> deleteSpot(double latitude, double longitude);

  /// Crea una nueva lista personalizada de spots.
  Future<CustomSpotModel> createCustomSpot(CustomSpotModel customSpot);

  /// Obtiene todas las listas personalizadas del usuario.
  Future<List<CustomSpotModel>> getCustomSpots();

  /// Añade un spot a una lista personalizada existente.
  Future<CustomSpotModel> addSpotToList(String listName, SpotModel spot);

  /// Elimina una lista personalizada completa.
  Future<int> deleteCustomSpotList(String listName);

  /// Elimina un spot específico de una lista personalizada.
  Future<int> deleteSpotFromList(
    String listName,
    double latitude,
    double longitude,
  );
}

/// Implementación de [SpotRemoteDatasource] usando HTTP client.
class SpotRemoteDatasourceImpl implements SpotRemoteDatasource {
  final http.Client client;
  final String Function() getToken;

  const SpotRemoteDatasourceImpl({
    required this.client,
    required this.getToken,
  });

  /// Añade un spot a una lista personalizada mediante POST request.
  /// Lanza [ServerException] si el request falla.
  /// Lanza [NetworkException] si hay problemas de conectividad.
  @override
  Future<CustomSpotModel> addSpotToList(String listName, SpotModel spot) async {
    try {
      final token = getToken();

      final response = await client.post(
        Uri.parse(ApiConstants.addSpotToList(listName)),
        headers: {...ApiConstants.authHeaders(token)},
        body: jsonEncode(spot.toJson()),
      );

      final String responseBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonResponse['data'] as Map<String, dynamic>;
        return CustomSpotModel.fromJson(data);
      } else {
        throw ServerException('Error con el servidor');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw NetworkException('No se pudo conectar al servidor');
      }
      rethrow;
    }
  }

  /// Crea una nueva lista personalizada mediante POST request.
  /// Lanza [ServerException] si el request falla.
  /// Lanza [NetworkException] si hay problemas de conectividad.
  @override
  Future<CustomSpotModel> createCustomSpot(CustomSpotModel customSpot) async {
    try {
      final token = getToken();

      final response = await client.post(
        Uri.parse(ApiConstants.createCustomSpot),
        headers: {...ApiConstants.authHeaders(token)},
        body: json.encode(customSpot.toJson()),
      );

      final String responseBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonResponse['data'] as Map<String, dynamic>;
        return CustomSpotModel.fromJson(data);
      } else {
        throw ServerException('Error de servidor');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw NetworkException('No se pudo conectar al servidor');
      }
      rethrow;
    }
  }

  /// Crea un nuevo spot en el backend mediante POST request.
  /// Lanza [ServerException] si el request falla.
  /// Lanza [NetworkException] si hay problemas de conectividad.
  @override
  Future<SpotModel> createSpot(SpotModel spot) async {
    try {
      final token = getToken();
      final response = await client.post(
        Uri.parse(ApiConstants.createSpot),
        headers: {...ApiConstants.authHeaders(token)},
        body: json.encode(spot.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final String responseBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> jsonResponse = json.decode(responseBody);
        final Map<String, dynamic> data = jsonResponse['data'];
        return SpotModel.fromJson(data);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Token inválido o expirado');
      } else if (response.statusCode == 409) {
        throw ConflictException('El spot ya existe en esta ubicación');
      } else {
        throw ServerException('Error al crear el spot', response.statusCode);
      }
    } on http.ClientException {
      throw NetworkException('No se pudo conectar al servidor');
    }
  }

  /// Elimina una lista personalizada completa mediante DELETE request.
  /// Lanza [ServerException] si el request falla.
  /// Lanza [NetworkException] si hay problemas de conectividad.
  @override
  Future<int> deleteCustomSpotList(String listName) async {
    try {
      final token = getToken();

      final response = await client.delete(
        Uri.parse(ApiConstants.deleteCustomSpotList(listName)),
        headers: {...ApiConstants.authHeaders(token)},
      );

      final String responseBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);

      if (response.statusCode == 200) {
        return jsonResponse['data'] as int;
      } else {
        throw ServerException('Error de servidor');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw NetworkException('No se pudo conectar al servidor');
      }
      rethrow;
    }
  }

  /// Elimina un spot por ubicación mediante DELETE request.
  /// Lanza [ServerException] si el request falla.
  /// Lanza [NetworkException] si hay problemas de conectividad.
  @override
  Future<int> deleteSpot(double latitude, double longitude) async {
    try {
      final token = getToken();

      final response = await client.delete(
        Uri.parse(ApiConstants.deleteSpot),
        headers: {...ApiConstants.authHeaders(token)},
        body: json.encode({'latitude': latitude, 'longitude': longitude}),
      );

      final String responseBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);

      if (response.statusCode == 200) {
        return jsonResponse['data'] as int;
      } else {
        throw ServerException('Error de servidor');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw NetworkException('No se pudo conectar al servidor');
      }
      rethrow;
    }
  }

  /// Elimina un spot de una lista personalizada mediante DELETE request.
  /// Lanza [ServerException] si el request falla.
  /// Lanza [NetworkException] si hay problemas de conectividad.
  @override
  Future<int> deleteSpotFromList(
    String listName,
    double latitude,
    double longitude,
  ) async {
    try {
      final token = getToken();

      final response = await client.delete(
        Uri.parse(ApiConstants.deleteSpotFromList(listName)),
        headers: {...ApiConstants.authHeaders(token)},
        body: json.encode({'latitude': latitude, 'longitude': longitude}),
      );

      final String responseBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);

      if (response.statusCode == 200) {
        return jsonResponse['data'] as int;
      } else {
        throw ServerException('Error de servidor');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw NetworkException('No se pudo conectar al servidor');
      }
      rethrow;
    }
  }

  /// Obtiene todas las listas personalizadas del usuario mediante GET request.
  /// Lanza [ServerException] si el request falla.
  /// Lanza [NetworkException] si hay problemas de conectividad.
  @override
  Future<List<CustomSpotModel>> getCustomSpots() async {
    try {
      final token = getToken();

      final response = await client.get(
        Uri.parse(ApiConstants.customSpots),
        headers: {...ApiConstants.authHeaders(token)},
      );

      final String responseBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);

      if (response.statusCode == 200) {
        final data = jsonResponse['data'] as List<dynamic>;
        return data
            .map(
              (json) => CustomSpotModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw ServerException('Error de servidor');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw NetworkException('No se pudo conectar al servidor');
      }
      rethrow;
    }
  }

  /// Obtiene los spots del usuario autenticado mediante GET request.
  /// Lanza [ServerException] si el request falla.
  /// Lanza [NetworkException] si hay problemas de conectividad.
  @override
  Future<List<SpotModel>> getUserSpots() async {
    try {
      final token = getToken();

      final response = await client.get(
        Uri.parse(ApiConstants.userSpots),
        headers: {...ApiConstants.authHeaders(token)},
      );

      final String responseBody = utf8.decode(response.bodyBytes);

      final Map<String, dynamic> jsonResponse = json.decode(responseBody);

      if (response.statusCode == 200) {
        final data = jsonResponse['data'] as List<dynamic>;
        return data
            .map((json) => SpotModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException('Error de servidor');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw NetworkException('No se pudo conectar al servidor');
      }
      rethrow;
    }
  }
}
