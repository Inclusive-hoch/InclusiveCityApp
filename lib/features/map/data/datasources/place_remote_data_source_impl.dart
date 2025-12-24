import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:inclusivecity_frontend/core/error/exception/exceptions.dart';
import 'package:inclusivecity_frontend/features/map/data/datasources/place_remote_data_source.dart';
import 'package:inclusivecity_frontend/features/map/data/models/place_detail_model.dart';
import 'package:inclusivecity_frontend/features/map/data/models/place_model.dart';
import 'package:inclusivecity_frontend/constants/api_constants.dart';

class BackendPlacesDataSourceImpl implements PlaceRemoteDataSource {
  final http.Client client;

  BackendPlacesDataSourceImpl({required this.client});

  @override
  Future<List<PlaceModel>> getPlaceSuggestions(String query) async {
    final response = await client.post(
      Uri.parse(ApiConstants.placesSearch),
      headers: {
        ...ApiConstants.jsonHeaders,
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: utf8.encode(json.encode(query)),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);
      final List dataList = jsonResponse['data'] as List;

      print("Backend response - Total lugares: ${dataList.length}");
      
      // Convertir PlaceSearchResponseDTO a PlaceModel
      final places = dataList
          .map((json) {
            print(" Lugar: ${json['name']} - Dirección: ${json['address']}");
            return PlaceModel.fromBackendJson(json);
          })
          .toList();
      
      return places;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<PlaceDetailsModel> getPlaceDetails(String placeId) async {
    final response = await client.get(
      Uri.parse(ApiConstants.placeDetails(placeId)),
      headers: {
        ...ApiConstants.jsonHeaders,
        'Content-Type': 'application/json; charset=utf-8',
      },
      // headers: ApiConstants.authHeaders(token), // Usar cuando tengas auth
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);
      final Map<String, dynamic> data = jsonResponse['data'];
      return PlaceDetailsModel.fromJson(data);
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<PlaceDetailsModel>> getNearbyPlaces(double lat, double lng, int radius) async {
    // TODO: Backend no tiene este endpoint aún
    // Podrías usar search con coordenadas o implementarlo después
    throw UnimplementedError('Backend endpoint not implemented yet');
  }
}