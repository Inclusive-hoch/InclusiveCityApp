import '../entities/sector_incidence_entity.dart';
import '../repositories/incident_repository.dart';

/// Caso de uso para obtener las incidencias en un sector del mapa.
///
/// Recibe las coordenadas de los límites visibles del mapa (NE y SW)
/// y retorna las incidencias registradas dentro de ese sector.
class GetSectorIncidences {
  final IncidentRepository repository;

  GetSectorIncidences(this.repository);

  Future<List<SectorIncidenceEntity>> call({
    required double northEastLat,
    required double northEastLng,
    required double southWestLat,
    required double southWestLng,
  }) {
    return repository.getIncidencesBySector(
      northEastLat: northEastLat,
      northEastLng: northEastLng,
      southWestLat: southWestLat,
      southWestLng: southWestLng,
    );
  }
}
