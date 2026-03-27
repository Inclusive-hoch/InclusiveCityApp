import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:inclusive_app/core/constants/api_constants.dart';
import 'package:inclusive_app/core/errors/exceptions.dart';
import 'package:inclusive_app/features/reviews/data/models/review_stat_data_request_model.dart';

abstract class ReviewRemoteDataSource {
  Future<void> savePlaceStatData({
    required String placeId,
    required ReviewStatDataRequestModel request,
  });

  Future<void> updatePlaceStatData({
    required String placeId,
  });
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final http.Client client;
  final Future<String> Function() getToken;

  const ReviewRemoteDataSourceImpl({
    required this.client,
    required this.getToken,
  });

  @override
  Future<void> savePlaceStatData({
    required String placeId,
    required ReviewStatDataRequestModel request,
  }) async {
    final token = await getToken();
    final uri = Uri.parse(ApiConstants.placeStatDataSave(placeId));

    developer.log(
      'POST $uri | payload=${json.encode(request.toJson())}',
      name: 'ReviewRemoteDataSource',
    );

    try {
      final response = await client.post(
        uri,
        headers: ApiConstants.authHeaders(token),
        body: json.encode(request.toJson()),
      );

      _throwIfNotSuccess(
        response,
        endpointName: 'savePlaceStatData',
      );

      developer.log(
        'savePlaceStatData success | status=${response.statusCode}',
        name: 'ReviewRemoteDataSource',
      );
    } on SocketException {
      throw NetworkException('No hay conexion a internet.');
    }
  }

  @override
  Future<void> updatePlaceStatData({required String placeId}) async {
    final token = await getToken();
    final uri = Uri.parse(ApiConstants.placeStatDataUpdate(placeId));

    developer.log(
      'GET $uri',
      name: 'ReviewRemoteDataSource',
    );

    try {
      final response = await client.get(
        uri,
        headers: ApiConstants.authHeaders(token),
      );

      _throwIfNotSuccess(
        response,
        endpointName: 'updatePlaceStatData',
      );

      developer.log(
        'updatePlaceStatData success | status=${response.statusCode}',
        name: 'ReviewRemoteDataSource',
      );
    } on SocketException {
      throw NetworkException('No hay conexion a internet.');
    }
  }

  void _throwIfNotSuccess(
    http.Response response, {
    required String endpointName,
  }) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    final message = _extractErrorMessage(response.body, response.statusCode);

    developer.log(
      '$endpointName failed | status=${response.statusCode} | body=${response.body}',
      name: 'ReviewRemoteDataSource',
    );

    switch (response.statusCode) {
      case 400:
        throw BadRequestException(message);
      case 401:
        throw UnauthorizedException(message);
      case 403:
        throw ForbiddenException(message);
      case 404:
        throw NotFoundException(message);
      case 409:
        throw ConflictException(message);
      case 500:
        throw InternalServerException(message, response.statusCode);
      default:
        throw ServerException(message, response.statusCode);
    }
  }

  String _extractErrorMessage(String rawBody, int statusCode) {
    if (rawBody.isEmpty) {
      return 'Error HTTP $statusCode';
    }

    try {
      final decoded = json.decode(rawBody);
      if (decoded is Map<String, dynamic>) {
        final dataMessage = decoded['message'];
        if (dataMessage is String && dataMessage.trim().isNotEmpty) {
          return dataMessage;
        }

        final errorField = decoded['error'];
        if (errorField is String && errorField.trim().isNotEmpty) {
          return errorField;
        }
      }
    } catch (_) {
      // Ignorar errores de parseo y usar el body raw.
    }

    return rawBody;
  }
}
