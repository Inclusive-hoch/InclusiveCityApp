import 'package:dartz/dartz.dart';
import 'package:inclusivecity_frontend/core/error/exception/exceptions.dart';
import 'package:inclusivecity_frontend/core/error/failure/failure.dart';
import 'package:inclusivecity_frontend/features/map/data/datasources/place_remote_data_source.dart';
import 'package:inclusivecity_frontend/features/map/data/datasources/place_local_data_source.dart'; // Asegúrate de importar esto
import 'package:inclusivecity_frontend/features/map/domain/entities/place_details.dart';
import 'package:inclusivecity_frontend/features/map/domain/entities/place_suggestion.dart';
import 'package:inclusivecity_frontend/features/map/domain/repositories/place_repository.dart';
import 'package:inclusivecity_frontend/core/network/network_info.dart';
import 'package:inclusivecity_frontend/features/map/data/models/place_model.dart'; // Necesario para el cast

class PlaceRepositoryImpl implements PlaceRepository {
  final PlaceRemoteDataSource remoteDataSource;
  final PlaceLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  PlaceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<PlaceSuggestion>>> searchPlaces(String query) async {
    if (await networkInfo.isConnected) {
      try {
        final places = await remoteDataSource.getPlaceSuggestions(query);
        return Right(places);
      } on ServerException {
        return Left(ServerFailure("Error al obtener los lugares. Por favor, inténtalo de nuevo más tarde."));
      }
    } else {
      return Left(ServerFailure("Sin conexión a internet. Verifica tu red."));
    }
  }

  @override
  Future<Either<Failure, PlaceDetails>> getPlaceDetails(String placeId) async {
    if (await networkInfo.isConnected) {
      try {
        final details = await remoteDataSource.getPlaceDetails(placeId);
        return Right(details);
      } on ServerException {
        return Left(ServerFailure("No se pudieron obtener los resultados."));
      }
    } else {
      return Left(ServerFailure("Sin conexión a internet."));
    }
  }

  @override
  Future<Either<Failure, List<PlaceDetails>>> getNearbyPlaces(double lat, double lng, {int radius = 5000}) async {
    if (await networkInfo.isConnected) {
      try {
        final places = await remoteDataSource.getNearbyPlaces(lat, lng, radius);
        return Right(places);
      } on ServerException {
        return Left(ServerFailure("Error de comunicación con el servidor."));
      }
    } else {
      return Left(ServerFailure("Sin conexión a internet."));
    }
  }


  //-------- Implementación del historial.
  @override
  Future<Either<Failure, List<PlaceSuggestion>>> getSearchHistory() async {
    try {
      final localHistory = await localDataSource.getLastSearches();
      return Right(localHistory);
    } on CacheException {
      return Left(CacheFailure("Error al intentar recuperar la memoria cache"));
    }
  }

  @override
  Future<Either<Failure, void>> savePlaceToHistory(PlaceSuggestion place) async {
    try {
      final placeModel = PlaceModel(
        placeId: place.placeId, 
        description: place.description, 
        address: place.address,
      );
      
      await localDataSource.cacheSearch(placeModel);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure("Error al intentar recuperar la memoria cache"));
    }
  }
}