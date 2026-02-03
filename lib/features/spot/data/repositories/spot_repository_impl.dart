import 'package:inclusive_app/features/spot/data/datasources/spot_remote_datasource.dart';
import 'package:inclusive_app/features/spot/data/models/custom_spot_model.dart';
import 'package:inclusive_app/features/spot/data/models/spot_model.dart';
import 'package:inclusive_app/features/spot/domain/entities/custom_spot.dart';
import 'package:inclusive_app/features/spot/domain/entities/spot.dart';
import 'package:inclusive_app/features/spot/domain/repositories/spot_repository.dart';

/// Implementación del repositorio de spots.
/// 
/// Coordina las operaciones con la fuente de datos remota,
/// convirtiendo entre entidades de dominio y modelos de datos.
class SpotRepositoryImpl implements SpotRepository {
  final SpotRemoteDatasource remoteDataSource;

  const SpotRepositoryImpl({
    required this.remoteDataSource,
  });

  /// Crea un nuevo spot en el servidor.
  /// 
  /// Convierte la entidad [Spot] a [SpotModel] antes de enviarla.
  /// Retorna el spot creado como entidad de dominio.
  @override
  Future<Spot> createSpot(Spot spot) async {
    final spotModel = SpotModel.fromEntity(spot);
    final result = await remoteDataSource.createSpot(spotModel);
    return result.toEntity();
  }

  /// Obtiene todos los spots de un usuario específico.
  /// 
  /// Retorna una lista de entidades [Spot] del dominio.
  @override
  Future<List<Spot>> getUserSpots(String userId) async {
    final spots = await remoteDataSource.getUserSpots();
    return spots.map((model) => model.toEntity()).toList();
  }

  /// Elimina un spot identificado por sus coordenadas.
  @override
  Future<void> deleteSpot(double latitude, double longitude) async {
    await remoteDataSource.deleteSpot(latitude, longitude);
  }

  /// Crea una nueva lista personalizada de spots.
  /// 
  /// Convierte la entidad [CustomSpot] a modelo antes de enviarla.
  @override
  Future<CustomSpot> createCustomSpot(CustomSpot customSpot) async {
    final model = CustomSpotModel.fromEntity(customSpot);
    final result = await remoteDataSource.createCustomSpot(model);
    return result;
  }

  /// Obtiene todas las listas personalizadas de spots.
  @override
  Future<List<CustomSpotModel>> getCustomSpots() async {
    final lists = await remoteDataSource.getCustomSpots();
    return lists;
  }

  /// Agrega un spot a una lista personalizada existente.
  /// 
  /// Retorna la lista actualizada con el nuevo spot incluido.
  @override
  Future<CustomSpotModel> addSpotToList(
    String listName,
    SpotModel spot,
  ) async {
    final result = await remoteDataSource.addSpotToList(listName, spot);
    return result;
  }

  /// Elimina una lista personalizada completa.
  /// 
  /// Retorna el número de listas eliminadas.
  @override
  Future<int> deleteCustomSpotList(String listName) async {
    return await remoteDataSource.deleteCustomSpotList(listName);
  }

  /// Elimina un spot específico de una lista personalizada.
  /// 
  /// Retorna el número de spots eliminados.
  @override
  Future<int> deleteSpotFromList(
    String listName,
    double latitude,
    double longitude,
  ) async {
    return await remoteDataSource.deleteSpotFromList(listName, latitude, longitude);
  }
}