import 'package:inclusive_app/core/errors/exceptions.dart';
import 'package:inclusive_app/core/network/network_info.dart';
import 'package:inclusive_app/features/places/data/datasources/place_local_datasource.dart';
import 'package:inclusive_app/features/places/data/datasources/place_remote_datasource.dart';
import 'package:inclusive_app/features/places/domain/entities/place_details.dart';
import 'package:inclusive_app/features/places/domain/entities/place_search_result.dart';
import 'package:inclusive_app/features/places/domain/repositories/place_repository.dart';
import 'package:inclusive_app/features/places/data/models/place_search_result_model.dart';

/// Implementación del repositorio de lugares.
/// 
/// Coordina entre las fuentes de datos remotas y locales,
/// gestiona la conectividad de red y convierte excepciones
/// de capa de datos en respuestas apropiadas.
class PlaceRepositoryImpl implements PlaceRepository {
  final PlaceRemoteDataSource remoteDataSource;
  final PlaceLocalDataSource localDataSource;
  final NetworkInfoImpl networkInfo;

  const PlaceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  /// Obtiene los detalles completos de un lugar específico.
  /// 
  /// Verifica la conexión antes de realizar la solicitud.
  /// 
  /// Lanza [NetworkException] si no hay conexión a internet.
  /// Lanza [ServerException] si falla la obtención de datos del servidor.
  @override
  Future<PlaceDetails> getPlaceDetails(String placeId) async {
    if (!(await networkInfo.isConnected)) {
      throw NetworkException(
        'No hay conexión a internet. Verifica tu conexión e intenta nuevamente.',
      );
    }

    try {
      final details = await remoteDataSource.getPlaceDetails(placeId);
      return details;
    } on ServerException catch (e) {
      throw ServerException(
        'Error al obtener los detalles del lugar: ${e.message}',
      );
    }
  }

  /// Recupera el historial de búsquedas guardadas localmente.
  /// 
  /// Retorna lista vacía si no hay historial.
  /// Lanza [CacheException] si falla la recuperación del caché.
  @override
  Future<List<PlaceSearchResult>> getSearchHistory() async {
    try {
      final localHistory = await localDataSource.getPlaceSearches();
      return localHistory;
    } on CacheException catch (e) {
      throw CacheException(
        'No se pudo recuperar el historial de búsquedas: ${e.message}',
      );
    }
  }

  /// Guarda un lugar en el historial de búsquedas local.
  /// 
  /// Convierte la entidad de dominio en modelo de datos
  /// antes de persistirla en caché.
  /// 
  /// Lanza [CacheException] si falla el guardado en caché.
  @override
  Future<void> savePlaceToHistory(PlaceSearchResult place) async {
    try {
      final placeSearchResultModel = PlaceSearchResultModel(
        placeId: place.placeId,
        description: place.description,
        address: place.address,
      );
      await localDataSource.cacheSearch(placeSearchResultModel);
    } on CacheException catch (e) {
      throw CacheException(
        'No se pudo guardar el lugar en el historial: ${e.message}',
      );
    }
  }

  /// Busca lugares mediante una consulta de texto.
  /// 
  /// Verifica la conexión antes de realizar la búsqueda.
  /// 
  /// Lanza [NetworkException] si no hay conexión a internet.
  /// Lanza [ServerException] si falla la búsqueda en el servidor.
  @override
  Future<List<PlaceSearchResult>> searchPlaces(String query) async {
    if (!(await networkInfo.isConnected)) {
      throw NetworkException(
        'No hay conexión a internet. No se puede realizar la búsqueda.',
      );
    }

    try {
      final places = await remoteDataSource.getPlaceSearchResults(query);
      return places;
    } on ServerException catch (e) {
      throw ServerException('Error al buscar lugares: ${e.message}');
    }
  }
}
