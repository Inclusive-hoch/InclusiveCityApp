import '../../domain/entities/incident_entity.dart';
import '../../domain/entities/sector_incidence_entity.dart';
import '../../domain/repositories/incident_repository.dart';
import '../datasources/incident_remote_datasource.dart';
import '../models/incident_model.dart';

/// Implementación concreta del repositorio de incidencias.
///
/// Coordina la comunicación entre el dominio y el datasource remoto,
/// mapeando entre entidades y modelos.
class IncidentRepositoryImpl implements IncidentRepository {
  final IncidentRemoteDataSource remoteDataSource;

  IncidentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<IncidentEntity> createIncident(IncidentEntity incident) async {
    final model = IncidentModel.fromEntity(incident);
    final result = await remoteDataSource.createIncident(
      model,
      photoPath: incident.photoPath,
    );
    return result.toEntity();
  }

  @override
  Future<List<SectorIncidenceEntity>> getIncidencesBySector({
    required double northEastLat,
    required double northEastLng,
    required double southWestLat,
    required double southWestLng,
  }) async {
    final models = await remoteDataSource.getIncidencesBySector(
      northEastLat: northEastLat,
      northEastLng: northEastLng,
      southWestLat: southWestLat,
      southWestLng: southWestLng,
    );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> insertIncidence({
    required String placeId,
    required double latitude,
    required double longitude,
    required String incidence,
    String image = '',
  }) async {
    await remoteDataSource.insertIncidence(
      placeId: placeId,
      latitude: latitude,
      longitude: longitude,
      incidence: incidence,
      image: image,
    );
  }
}
