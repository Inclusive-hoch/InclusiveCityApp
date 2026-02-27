import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:inclusive_app/core/auth/firebase_auth_service.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/incidents/domain/entities/sector_incidence_entity.dart';
import 'package:inclusive_app/features/incidents/domain/repositories/incident_repository.dart';
import 'package:inclusive_app/features/incidents/presentation/constants/incidence_marker_icons.dart';
import 'package:inclusive_app/injection_container.dart' as di;
import 'package:inclusive_app/shared/widgets/grabber.dart';

/// Vista de detalle de incidencias como bottom sheet draggable.
///
/// Muestra la lista de imágenes de las incidencias seleccionadas
/// siguiendo el lenguaje de diseño de la aplicación.
class IncidenceDetailSheet extends StatelessWidget {
  final List<SectorIncidenceEntity> incidences;

  const IncidenceDetailSheet({super.key, required this.incidences});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.2,
      maxChildSize: 0.85,
      snap: true,
      snapSizes: const [0.2, 0.45, 0.85],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Grabber
              const Center(child: Grabber()),
              const SizedBox(height: 8),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: AppColor.primaryNormalActive,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        getIncidenceIcon(incidences.first.incidence),
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            incidences.first.incidence,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '${incidences.length} reporte${incidences.length > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        color: AppColor.primaryNormal,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Sección de reportar nuevamente
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Text(
                      '¿Sigue activa la incidencia?',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _onReportAgain(context),
                        icon: const Icon(Icons.refresh, size: 20),
                        label: const Text('Reportar nuevamente'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryNormal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Lista de imágenes
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: incidences.length,
                  itemBuilder: (context, index) {
                    return _buildImageCard(incidences[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Re-reporta la incidencia usando los datos existentes y el userId actual.
  Future<void> _onReportAgain(BuildContext context) async {
    final incidence = incidences.first;

    try {
      final userId = di.sl<FirebaseAuthService>().currentUser?.uid ?? '';
      final repository = di.sl<IncidentRepository>();

      await repository.insertIncidence(
        placeId: incidence.placeId,
        latitude: incidence.latitude,
        longitude: incidence.longitude,
        incidence: incidence.incidence,
        userId: userId,
      );

      log(
        'Incidencia re-reportada: ${incidence.incidence} '
        '(placeId: ${incidence.placeId})',
      );

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incidencia reportada nuevamente'),
            backgroundColor: AppColor.greenNormal,
          ),
        );
      }
    } catch (e) {
      log('Error al re-reportar: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al reportar la incidencia'),
            backgroundColor: AppColor.redNormal,
          ),
        );
      }
    }
  }

  Widget _buildImageCard(SectorIncidenceEntity incidence) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: incidence.image != null && incidence.image!.isNotEmpty
            ? Image.network(
                incidence.image!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 220,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 220,
                    color: AppColor.neutralNormal,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                        color: AppColor.primaryNormal,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildNoImagePlaceholder();
                },
              )
            : _buildNoImagePlaceholder(),
      ),
    );
  }

  Widget _buildNoImagePlaceholder() {
    return Container(
      height: 160,
      color: AppColor.neutralNormal,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 36,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 4),
            Text(
              'Sin imagen',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
