import 'package:inclusive_app/features/spot/data/models/custom_spot_model.dart';
import 'package:inclusive_app/features/spot/data/models/spot_model.dart';
import 'package:inclusive_app/features/spot/domain/entities/custom_spot.dart';
import 'package:inclusive_app/features/spot/domain/entities/spot.dart';

/// Repositorio para gestionar operaciones con spots y listas personalizadas.
/// 
/// Define el contrato para todas las operaciones relacionadas con:
/// - Creación, lectura y eliminación de spots individuales
/// - Gestión de listas personalizadas de spots
abstract class SpotRepository {
  /// Crea un nuevo spot en el sistema.
  Future<Spot> createSpot(Spot spot);

  /// Obtiene todos los spots asociados a un usuario.
  Future<List<Spot>> getUserSpots(String userId);

  /// Elimina un spot identificado por sus coordenadas.
  Future<void> deleteSpot(double latitude, double longitude);

  /// Crea una nueva lista personalizada de spots.
  Future<CustomSpot> createCustomSpot(CustomSpot customSpot);

  /// Obtiene todas las listas personalizadas del usuario.
  Future<List<CustomSpotModel>> getCustomSpots();

  /// Agrega un spot a una lista personalizada existente.
  Future<CustomSpotModel> addSpotToList(String listName, SpotModel spot);

  /// Elimina una lista personalizada completa.
  /// 
  /// Retorna el número de listas eliminadas.
  Future<int> deleteCustomSpotList(String listName);

  /// Elimina un spot específico de una lista personalizada.
  /// 
  /// Retorna el número de spots eliminados.
  Future<int> deleteSpotFromList(
    String listName,
    double latitude,
    double longitude,
  );
}
