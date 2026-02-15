import 'dart:convert';
import 'package:flutter/foundation.dart';
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
  final Future<String> Function() getToken;

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
      final token = await getToken();

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
        final errorMsg = 'Error al agregar spot a lista "$listName". Status ${response.statusCode}: $responseBody';
        debugPrint('❌ [SpotDataSource] $errorMsg');
        throw ServerException(errorMsg, response.statusCode);
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw NetworkException('No se pudo conectar al servidor al agregar spot a lista: ${e.message}');
      }
      if (e is ServerException || e is NetworkException) rethrow;
      debugPrint('❌ [SpotDataSource] Error inesperado en addSpotToList: $e');
      rethrow;
    }
  }

  /// Crea una nueva lista personalizada mediante POST request.
  /// Lanza [ServerException] si el request falla.
  /// Lanza [NetworkException] si hay problemas de conectividad.
  @override
  Future<CustomSpotModel> createCustomSpot(CustomSpotModel customSpot) async {
    debugPrint('🔷 [SpotDataSource] Creando lista personalizada: ${customSpot.listName}');
    
    try {
      final token = await getToken();

      final response = await client.post(
        Uri.parse(ApiConstants.createCustomSpot),
        headers: {...ApiConstants.authHeaders(token)},
        body: json.encode(customSpot.toJson()),
      );

      final String responseBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonResponse['data'] as Map<String, dynamic>;
        debugPrint('✅ [SpotDataSource] Lista creada exitosamente');
        return CustomSpotModel.fromJson(data);
      } else {
        final errorMsg = 'Error al crear lista personalizada "${customSpot.listName}". Status ${response.statusCode}: $responseBody';
        debugPrint('❌ [SpotDataSource] $errorMsg');
        throw ServerException(errorMsg, response.statusCode);
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw NetworkException('No se pudo conectar al servidor al crear lista personalizada: ${e.message}');
      }
      if (e is ServerException || e is NetworkException) rethrow;
      debugPrint('❌ [SpotDataSource] Error inesperado en createCustomSpot: $e');
      rethrow;
    }
  }

  /// Crea un nuevo spot en el backend mediante POST request.
  /// Lanza [ServerException] si el request falla.
  /// Lanza [NetworkException] si hay problemas de conectividad.
  @override
  Future<SpotModel> createSpot(SpotModel spot) async {
    debugPrint('🔷 [SpotDataSource] Creando spot: ${spot.spotName}');
    
    try {
      final token = await getToken();
      final response = await client.post(
        Uri.parse(ApiConstants.createSpot),
        headers: {...ApiConstants.authHeaders(token)},
        body: json.encode(spot.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final String responseBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> jsonResponse = json.decode(responseBody);
        final Map<String, dynamic> data = jsonResponse['data'];
        debugPrint('✅ [SpotDataSource] Spot creado exitosamente');
        return SpotModel.fromJson(data);
      } else if (response.statusCode == 401) {
        debugPrint('❌ [SpotDataSource] Token inválido o expirado');
        throw UnauthorizedException('Token inválido o expirado al crear spot "${spot.spotName}"');
      } else if (response.statusCode == 409) {
        debugPrint('⚠️ [SpotDataSource] Spot duplicado en ubicación (${spot.latitude}, ${spot.longitude})');
        throw ConflictException('El spot "${spot.spotName}" ya existe en esta ubicación');
      } else {
        final String responseBody = utf8.decode(response.bodyBytes);
        final errorMsg = 'Error al crear spot "${spot.spotName}". Status ${response.statusCode}: $responseBody';
        debugPrint('❌ [SpotDataSource] $errorMsg');
        throw ServerException(errorMsg, response.statusCode);
      }
    } on http.ClientException catch (e) {
      throw NetworkException('No se pudo conectar al servidor al crear spot: ${e.message}');
    } catch (e) {
      if (e is UnauthorizedException || e is ConflictException || e is ServerException || e is NetworkException) {
        rethrow;
      }
      debugPrint('❌ [SpotDataSource] Error inesperado en createSpot: $e');
      rethrow;
    }
  }

  /// Elimina una lista personalizada completa mediante DELETE request.
  /// Lanza [ServerException] si el request falla.
  /// Lanza [NetworkException] si hay problemas de conectividad.
  @override
  Future<int> deleteCustomSpotList(String listName) async {
    try {
      final token = await getToken();

      final response = await client.delete(
        Uri.parse(ApiConstants.deleteCustomSpotList(listName)),
        headers: {...ApiConstants.authHeaders(token)},
      );

      final String responseBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);

      if (response.statusCode == 200) {
        return jsonResponse['data'] as int;
      } else {
        final errorMsg = 'Error al eliminar lista "$listName". Status ${response.statusCode}: $responseBody';
        debugPrint('❌ [SpotDataSource] $errorMsg');
        throw ServerException(errorMsg, response.statusCode);
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw NetworkException('No se pudo conectar al servidor al eliminar lista: ${e.message}');
      }
      if (e is ServerException || e is NetworkException) rethrow;
      debugPrint('❌ [SpotDataSource] Error inesperado en deleteCustomSpotList: $e');
      rethrow;
    }
  }

  /// Elimina un spot por ubicación mediante DELETE request.
  /// Lanza [ServerException] si el request falla.
  /// Lanza [NetworkException] si hay problemas de conectividad.
  @override
  Future<int> deleteSpot(double latitude, double longitude) async {
    try {
      final token = await getToken();

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
        final errorMsg = 'Error al eliminar spot en ($latitude, $longitude). Status ${response.statusCode}: $responseBody';
        debugPrint('❌ [SpotDataSource] $errorMsg');
        throw ServerException(errorMsg, response.statusCode);
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw NetworkException('No se pudo conectar al servidor al eliminar spot: ${e.message}');
      }
      if (e is ServerException || e is NetworkException) rethrow;
      debugPrint('❌ [SpotDataSource] Error inesperado en deleteSpot: $e');
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
      final token = await getToken();

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
        final errorMsg = 'Error al eliminar spot de lista "$listName". Status ${response.statusCode}: $responseBody';
        debugPrint('❌ [SpotDataSource] $errorMsg');
        throw ServerException(errorMsg, response.statusCode);
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw NetworkException('No se pudo conectar al servidor al eliminar spot de lista: ${e.message}');
      }
      if (e is ServerException || e is NetworkException) rethrow;
      debugPrint('❌ [SpotDataSource] Error inesperado en deleteSpotFromList: $e');
      rethrow;
    }
  }

  /// Obtiene todas las listas personalizadas del usuario mediante GET request.
  /// Lanza [ServerException] si el request falla.
  /// Lanza [NetworkException] si hay problemas de conectividad.
  @override
  Future<List<CustomSpotModel>> getCustomSpots() async {
    try {
      final token = await getToken();

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
        final errorMsg = 'Error al obtener listas personalizadas. Status ${response.statusCode}: $responseBody';
        debugPrint('❌ [SpotDataSource] $errorMsg');
        throw ServerException(errorMsg, response.statusCode);
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw NetworkException('No se pudo conectar al servidor al obtener listas: ${e.message}');
      }
      if (e is ServerException || e is NetworkException) rethrow;
      debugPrint('❌ [SpotDataSource] Error inesperado en getCustomSpots: $e');
      rethrow;
    }
  }

  /// Obtiene los spots del usuario autenticado mediante GET request.
  /// Lanza [ServerException] si el request falla.
  /// Lanza [NetworkException] si hay problemas de conectividad.
  @override
  Future<List<SpotModel>> getUserSpots() async {
    try {
      final token = await getToken();

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
        final errorMsg = 'Error al obtener spots del usuario. Status ${response.statusCode}: $responseBody';
        debugPrint('❌ [SpotDataSource] $errorMsg');
        throw ServerException(errorMsg, response.statusCode);
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw NetworkException('No se pudo conectar al servidor al obtener spots: ${e.message}');
      }
      if (e is ServerException || e is NetworkException) rethrow;
      debugPrint('❌ [SpotDataSource] Error inesperado en getUserSpots: $e');
      rethrow;
    }
  }
}
