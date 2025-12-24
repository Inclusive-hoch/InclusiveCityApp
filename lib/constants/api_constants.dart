import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Base URLs - Cargar desde .env
  // Usar 10.0.2.2 para emulador Android (localhost de la máquina host)
  // Para dispositivo físico, usa la IP de tu PC en el .env (ej: http://192.168.1.100:8080)
  static String get gatewayUrl => dotenv.env['BACKEND_GATEWAY_URL'] ?? 'http://localhost:8080';
  static const String baseApiPath = "/inclusive/api/v1";
  static String get baseUrl => "$gatewayUrl$baseApiPath";

  // === LOCATION API (puerto 8070) ===
  // Places endpoints
  static String get placesBase => "$baseUrl/location/place";
  static String get placesSearch => "$placesBase/search";
  static String placeDetails(String placeId) => "$placesBase/$placeId";
  static String placePhoto(String photoReference) => "$placesBase/photo/$photoReference";

  // Spots endpoints
  static String get spotsBase => "$baseUrl/location/spot";
  static String get createSpot => "$spotsBase/insert";
  static String userSpots(String userId) => "$spotsBase/$userId";

  // Incidence endpoints
  static String get incidenceBase => "$baseUrl/incidence";
  static String get createIncidence => incidenceBase;
  static String get allIncidences => "$incidenceBase/all";

  // === ROUTE API (puerto 8060) ===
  static String get routeBase => "$baseUrl/routes";

  // === ACCOUNT API (puerto 8090) ===
  static String get profileBase => "$baseUrl/profile";
  static String get formsBase => "$baseUrl/form";

  // === AUTHENTICATION (puerto 9090) ===
  static String get login => "$baseUrl/login";
  static String get register => "$baseUrl/register";
  static String get resetPassword => "$baseUrl/reset";

  // Headers
  static const Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
}