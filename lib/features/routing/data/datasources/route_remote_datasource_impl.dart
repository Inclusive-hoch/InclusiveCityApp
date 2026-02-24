import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inclusive_app/core/constants/api_constants.dart';
import 'package:inclusive_app/features/routing/data/datasources/route_remote_datasource.dart';
import 'package:inclusive_app/features/routing/data/models/route_info_model.dart';

/// Implementación del data source remoto para rutas.
/// 
/// Realiza peticiones HTTP al backend para obtener rutas calculadas.
class RouteRemoteDataSourceImpl implements RouteRemoteDataSource {
  final http.Client client;
  final Future<String> Function() getToken;

  const RouteRemoteDataSourceImpl({
    required this.client,
    required this.getToken,
  });

  @override
  Future<RouteInfoModel> getAlternativeRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    return _fetchRoute(
      endpoint: ApiConstants.secureRoute,
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
      routeType: 'alternative',
    );
  }

  /// Método privado para realizar la petición HTTP y parsear la respuesta.
  Future<RouteInfoModel> _fetchRoute({
    required String endpoint,
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    required String routeType,
  }) async {
    // Construir la URL con query parameters
    final origin = '$originLat,$originLng';
    final destination = '$destLat,$destLng';
    
    final uri = Uri.parse(endpoint).replace(
      queryParameters: {
        'origin': origin,
        'destination': destination,
      },
    );

    final token = await getToken();
    final response = await client.get(
      uri,
      headers: ApiConstants.authHeaders(token),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      
      return RouteInfoModel.fromJson(json, routeType: routeType);
    } else {
      throw Exception(
        'Error al obtener ruta: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
