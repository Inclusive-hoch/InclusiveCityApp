import '../models/incident_model.dart';

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
}
