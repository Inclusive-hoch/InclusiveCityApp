import 'package:flutter/foundation.dart';
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

  @override
  Future<Spot> createSpot(Spot spot) async {
    debugPrint('🔹 [SpotRepository] createSpot iniciado para: ${spot.spotName}');
    final spotModel = SpotModel.fromEntity(spot);
    final result = await remoteDataSource.createSpot(spotModel);
    return result.toEntity();
  }

  @override
  Future<List<Spot>> getUserSpots(String userId) async {
    final spots = await remoteDataSource.getUserSpots();
    return spots.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> deleteSpot(double latitude, double longitude) async {
    await remoteDataSource.deleteSpot(latitude, longitude);
  }

  @override
  Future<CustomSpot> createCustomSpot(CustomSpot customSpot) async {
    debugPrint('🔹 [SpotRepository] createCustomSpot iniciado para lista: ${customSpot.listName}');
    final model = CustomSpotModel.fromEntity(customSpot);
    final result = await remoteDataSource.createCustomSpot(model);
    return result;
  }

  @override
  Future<List<CustomSpotModel>> getCustomSpots() async {
    final lists = await remoteDataSource.getCustomSpots();
    return lists;
  }

  @override
  Future<CustomSpotModel> addSpotToList(
    String listName,
    SpotModel spot,
  ) async {
    final result = await remoteDataSource.addSpotToList(listName, spot);
    return result;
  }

  @override
  Future<int> deleteCustomSpotList(String listName) async {
    return await remoteDataSource.deleteCustomSpotList(listName);
  }

  @override
  Future<int> deleteSpotFromList(
    String listName,
    double latitude,
    double longitude,
  ) async {
    return await remoteDataSource.deleteSpotFromList(listName, latitude, longitude);
  }
}