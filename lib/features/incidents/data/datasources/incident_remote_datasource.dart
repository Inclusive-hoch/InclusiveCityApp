import '../models/incident_model.dart';
import '../models/sector_incidence_model.dart';

/// Contrato abstracto del datasource remoto de incidencias.
abstract class IncidentRemoteDataSource {
  /// Crea una incidencia en el backend.
  ///
  /// Recibe el [model] con los datos y opcionalmente un [photoPath]
  /// para subir la foto junto con la incidencia.
  Future<IncidentModel> createIncident(
    IncidentModel model, {
    String? photoPath,
  });

  /// Obtiene las incidencias registradas en un sector del mapa.
  Future<List<SectorIncidenceModel>> getIncidencesBySector({
    required double northEastLat,
    required double northEastLng,
    required double southWestLat,
    required double southWestLng,
  });

  /// Inserta/re-reporta una incidencia existente.
  Future<void> insertIncidence({
    required String placeId,
    required double latitude,
    required double longitude,
    required String incidence,
    String? userId,
    String image,
  });
}
