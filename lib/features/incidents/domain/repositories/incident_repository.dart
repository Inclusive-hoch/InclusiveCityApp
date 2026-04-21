import '../entities/incident_entity.dart';
import '../entities/sector_incidence_entity.dart';

/// Contrato abstracto del repositorio de incidencias.
abstract class IncidentRepository {
  Future<IncidentEntity> createIncident(IncidentEntity incident);

  /// Obtiene las incidencias registradas dentro de un sector del mapa
  /// definido por las coordenadas NE y SW.
  Future<List<SectorIncidenceEntity>> getIncidencesBySector({
    required double northEastLat,
    required double northEastLng,
    required double southWestLat,
    required double southWestLng,
  });

  /// Inserta/re-reporta una incidencia.
  Future<void> insertIncidence({
    required String placeId,
    required double latitude,
    required double longitude,
    required String incidence,
    String? userId,
    String image,
  });
}
