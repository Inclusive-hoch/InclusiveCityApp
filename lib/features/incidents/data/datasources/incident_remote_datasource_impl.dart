import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:inclusive_app/core/constants/api_constants.dart';
import 'package:inclusive_app/core/errors/exceptions.dart';
import '../models/incident_model.dart';
import '../models/sector_incidence_model.dart';
import 'incident_remote_datasource.dart';

/// Implementación concreta del datasource remoto de incidencias.
///
/// Utiliza HTTP client para comunicarse con el backend y
/// requiere un token de autenticación para cada petición.
class IncidentRemoteDataSourceImpl implements IncidentRemoteDataSource {
  final http.Client client;
  final Future<String> Function() getToken;

  const IncidentRemoteDataSourceImpl({
    required this.client,
    required this.getToken,
  });

  @override
  Future<IncidentModel> createIncident(
    IncidentModel model, {
    String? photoPath,
  }) async {
    final token = await getToken();
    final response = await client.post(
      Uri.parse(ApiConstants.createIncidence),
      headers: {...ApiConstants.authHeaders(token)},
      body: json.encode(model.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);
      return IncidentModel.fromJson(jsonResponse['data']);
    } else {
      throw ServerException(
        'Error al crear la incidencia',
        response.statusCode,
      );
    }
  }

  @override
  Future<List<SectorIncidenceModel>> getIncidencesBySector({
    required double northEastLat,
    required double northEastLng,
    required double southWestLat,
    required double southWestLng,
  }) async {
    final token = await getToken();
    final response = await client.post(
      Uri.parse(ApiConstants.incidenceBySector),
      headers: {...ApiConstants.authHeaders(token)},
      body: json.encode({
        'pointNorthEast': {
          'latitude': northEastLat.toString(),
          'longitude': northEastLng.toString(),
        },
        'pointSouthWest': {
          'latitude': southWestLat.toString(),
          'longitude': southWestLng.toString(),
        },
      }),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);
      final List dataList = jsonResponse['data'] as List;

      log('Incidencias en sector: ${dataList.length}');

      return dataList
          .map((json) => SectorIncidenceModel.fromJson(json))
          .toList();
    } else {
      throw ServerException(
        'Error al obtener incidencias del sector',
        response.statusCode,
      );
    }
  }

  @override
  Future<void> insertIncidence({
    required String placeId,
    required double latitude,
    required double longitude,
    required String incidence,
    String image = '',
  }) async {
    final token = await getToken();

    var resolvedImage = image.trim();
    if (resolvedImage.isNotEmpty && !_isRemoteUrl(resolvedImage)) {
      resolvedImage = await _uploadIncidenceImage(
        imagePath: resolvedImage,
        token: token,
      );
    }

    final response = await client.post(
      Uri.parse(ApiConstants.insertIncidence),
      headers: {...ApiConstants.authHeaders(token)},
      body: json.encode({
        'placeId': placeId,
        'location': {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
        },
        'incidence': incidence,
        'image': resolvedImage,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ServerException(
        'Error al reportar la incidencia',
        response.statusCode,
      );
    }
  }

  bool _isRemoteUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  Future<String> _uploadIncidenceImage({
    required String imagePath,
    required String token,
  }) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw ServerException('No se encontro la imagen capturada', 400);
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConstants.uploadIncidenceImage),
    )..headers['Authorization'] = 'Bearer $token';

    request.files.add(await http.MultipartFile.fromPath('file', imagePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ServerException(
        'No se pudo subir la imagen de la incidencia',
        response.statusCode,
      );
    }

    final Map<String, dynamic> jsonResponse = json.decode(
      utf8.decode(response.bodyBytes),
    );
    final data = jsonResponse['data'];

    if (data is! String || data.trim().isEmpty) {
      throw ServerException(
        'Respuesta invalida al subir la imagen de la incidencia',
        500,
      );
    }

    return data.trim();
  }
}
