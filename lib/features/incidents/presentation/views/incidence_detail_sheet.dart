import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/incidents/domain/entities/sector_incidence_entity.dart';
import 'package:inclusive_app/features/incidents/presentation/constants/incidence_marker_icons.dart';
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
              // Grabber (mismo que PlaceDetailsPage)
              const Center(child: Grabber()),
              const SizedBox(height: 8),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Ícono en círculo (mismo estilo que IncidentItem)
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
                        onPressed: () {
                          debugPrint(
                            'Reportar nuevamente: ${incidences.first.incidence} '
                            '(placeId: ${incidences.first.placeId})',
                          );
                          Navigator.pop(context);
                        },
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
