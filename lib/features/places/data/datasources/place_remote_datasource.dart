import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:inclusive_app/core/errors/exceptions.dart';
import 'package:inclusive_app/features/places/data/models/place_search_result_model.dart';
import 'package:inclusive_app/features/places/data/models/place_details_models.dart';
import 'package:inclusive_app/core/constants/api_constants.dart';

/// Fuente de datos remota para búsqueda de lugares.
abstract class PlaceRemoteDataSource {
  /// Busca lugares por query en el backend.
  Future<List<PlaceSearchResultModel>> getPlaceSearchResults(String query);
  
  /// Obtiene los detalles de un lugar específico.
  Future<PlaceDetailsModel> getPlaceDetails(String placeId);
}

/// Implementación de [PlaceRemoteDataSource] usando HTTP client.
class PlaceRemoteDataSourceImpl implements PlaceRemoteDataSource {
  final http.Client client;
  final String Function() getToken;

  const PlaceRemoteDataSourceImpl({
    required this.client,
    required this.getToken,
  });

  /// Busca lugares en el backend mediante POST request.
  /// Lanza [ServerException] si el request falla.
  @override
  Future<List<PlaceSearchResultModel>> getPlaceSearchResults(
    String query,
  ) async {
    final token = getToken();
    final response = await client.post(
      Uri.parse(ApiConstants.placesSearch),
      headers: {...ApiConstants.authHeaders(token)},
      body: json.encode({'query': query}),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);
      final List dataList = jsonResponse['data'] as List;

      log('Backend response - total lugares: ${dataList.length}');

      final places = dataList.map((json) {
        log(" Lugar: ${json['name']} - Dirección: ${json['address']}");
        return PlaceSearchResultModel.fromBackendJson(json);
      }).toList();

      return places;
    } else {
      throw ServerException('');
    }
  }

  /// Obtiene detalles de un lugar específico mediante GET request.
  /// Lanza [ServerException] si el request falla.
  @override
  Future<PlaceDetailsModel> getPlaceDetails(String placeId) async {
    final token = getToken();
    final response = await client.get(
      Uri.parse(ApiConstants.placeDetails(placeId)),
      headers: {...ApiConstants.authHeaders(token)},
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);
      final Map<String, dynamic> data = jsonResponse['data'];
      return PlaceDetailsModel.fromJson(data);
    } else {
      throw ServerException('');
    }
  }
}
