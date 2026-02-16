import '../entities/incident_entity.dart';

/// Contrato abstracto del repositorio de incidencias.
abstract class IncidentRepository {
  Future<IncidentEntity> createIncident(IncidentEntity incident);
}
