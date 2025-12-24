import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusivecity_frontend/constants/app_colors.dart';
import 'package:inclusivecity_frontend/core/auth/auth_service.dart';
import 'package:inclusivecity_frontend/features/map/domain/entities/place_details.dart';
import 'package:inclusivecity_frontend/features/map/domain/entities/spot_entity.dart';
import 'package:inclusivecity_frontend/features/map/presentation/bloc/spots_bloc.dart';
import 'package:inclusivecity_frontend/features/map/presentation/bloc/spots_event.dart';
import 'package:inclusivecity_frontend/features/map/presentation/widget/save_spot_dialog.dart';
import 'package:inclusivecity_frontend/constants/api_constants.dart';

/// Bottom Sheet deslizable que muestra los detalles completos de un lugar
/// Similar al diseño de Google Maps
class PlaceDetailsBottomSheet extends StatefulWidget {
  final PlaceDetails placeDetails;
  final VoidCallback onClose;
  
  const PlaceDetailsBottomSheet({
    super.key,
    required this.placeDetails,
    required this.onClose,
  });

  @override
  State<PlaceDetailsBottomSheet> createState() => _PlaceDetailsBottomSheetState();
}

class _PlaceDetailsBottomSheetState extends State<PlaceDetailsBottomSheet> {
  final _sheetController = DraggableScrollableController();
  int _selectedPhotoIndex = 0;

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.placeDetails;
    final hasPhotos = place.photos.isNotEmpty;
    final hasMedals = place.medals.isNotEmpty;
    
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.4,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              // Contenido principal
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    
                    // 1. Header: Nombre del lugar con botones de acción
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            place.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.neutralDarkDarker,
                            ),
                          ),
                        ),
                        _buildHeaderButtons(),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 2. Rating y porcentaje de aprobación
                    _buildRatingSection(place.rating),
                    
                    const SizedBox(height: 16),
                    
                    // 3. Medallas de accesibilidad
                    if (hasMedals) _buildMedalsSection(place.medals),
                    
                    const SizedBox(height: 16),
                    
                    // 4. Botones de acción (Generar ruta e Iniciar ruta)
                    _buildActionButtons(),
                    
                    const SizedBox(height: 16),
                    
                    // 5. Galería de fotos
                    if (hasPhotos) _buildPhotoGallery(place.photos),
                    
                    const SizedBox(height: 8),
                    
                    // Dirección debajo de la foto
                    _buildInfoRow(
                      Icons.location_on_outlined,
                      place.address,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 6. Botón de reseñar accesibilidad
                    _buildReviewButton(),
                    
                    const SizedBox(height: 16),
                    
                    // 7. Sección de feedback - ¿Qué te parece este lugar?
                    _buildFeedbackSection(),
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderButtons() {
    return Row(
      children: [
        // Botón de guardar
        IconButton(
          icon: const Icon(Icons.bookmark_border),
          color: AppColors.primaryNormal,
          iconSize: 28,
          onPressed: () => _showSaveSpotDialog(context),
        ),
        // Botón de compartir
        IconButton(
          icon: const Icon(Icons.share_outlined),
          color: AppColors.primaryNormal,
          iconSize: 28,
          onPressed: () {
            // TODO: Implementar compartir
            debugPrint('Compartir lugar: ${widget.placeDetails.placeId}');
          },
        ),
        // Botón cerrar
        IconButton(
          icon: const Icon(Icons.close),
          color: AppColors.neutralDarkDarker,
          iconSize: 28,
          onPressed: widget.onClose,
        ),
      ],
    );
  }

  void _showSaveSpotDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SaveSpotDialog(
        placeId: widget.placeDetails.placeId,
        address: widget.placeDetails.address,
        latitude: widget.placeDetails.latitude,
        longitude: widget.placeDetails.longitude,
      ),
    );

    if (result != null && mounted) {
      final userId = AuthService().requireUserId();
      
      final spot = SpotEntity(
        userId: userId,
        spotName: result['name'] as String,
        placeId: widget.placeDetails.placeId,
        address: widget.placeDetails.address,
        latitude: widget.placeDetails.latitude,
        longitude: widget.placeDetails.longitude,
        type: result['type'] as String,
      );

      context.read<SpotsBloc>().add(SaveSpotEvent(spot));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result['name']} guardado correctamente'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildPhotoGallery(List<String> photoReferences) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 200,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: photoReferences.length,
              onPageChanged: (index) {
                setState(() {
                  _selectedPhotoIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final photoUrl = ApiConstants.placePhoto(photoReferences[index]);
                return Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppColors.neutralLight,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.neutralLight,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: AppColors.neutralDarkNormal,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            
            // Indicador de posición
            if (photoReferences.length > 1)
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    photoReferences.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _selectedPhotoIndex == index
                            ? AppColors.primaryNormal
                            : AppColors.surface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection(double rating) {
    // Calcular porcentaje (rating viene como 0-100 del backend)
    final percentage = rating.toInt();
    final displayText = percentage > 0 ? '$percentage%' : 'Sin calificación';
    
    return Row(
      children: [
        const Icon(
          Icons.thumb_up,
          color: AppColors.primaryNormal,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          displayText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryNormal,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          percentage > 0 ? 'le gusta este lugar' : '',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.neutralDarkNormal,
          ),
        ),
      ],
    );
  }

  Widget _buildMedalsSection(List<String> medals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Características de Accesibilidad',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.neutralDarkDarker,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: medals.map((medal) => _buildMedalChip(medal)).toList(),
        ),
      ],
    );
  }

  Widget _buildMedalChip(String medal) {
    // Mapeo de iconos según el tipo de medalla
    IconData icon;
    switch (medal.toLowerCase()) {
      case 'rampa':
      case 'ramp':
        icon = Icons.accessible;
        break;
      case 'elevator':
      case 'ascensor':
        icon = Icons.elevator;
        break;
      case 'parking':
      case 'estacionamiento':
        icon = Icons.local_parking;
        break;
      case 'bathroom':
      case 'baño':
        icon = Icons.wc;
        break;
      default:
        icon = Icons.check_circle;
    }
    
    return Chip(
      avatar: Icon(icon, size: 18, color: AppColors.primaryNormal),
      label: Text(
        medal,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: AppColors.primaryLight,
      side: BorderSide.none,
    );
  }

  Widget _buildInfoRow(IconData icon, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.neutralDarkNormal, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.neutralDarkDarker,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Implementar generación de ruta
              debugPrint('Generar ruta hacia: ${widget.placeDetails.name}');
            },
            icon: const Icon(Icons.directions),
            label: const Text('Generar ruta'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNormal,
              foregroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implementar inicio de ruta
              debugPrint('Iniciar ruta hacia: ${widget.placeDetails.name}');
            },
            icon: const Icon(Icons.navigation),
            label: const Text('Iniciar ruta'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryNormal,
              side: const BorderSide(color: AppColors.primaryNormal, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Abrir pantalla completa de reseña detallada de accesibilidad
          debugPrint('Abrir formulario de reseña para: ${widget.placeDetails.placeId}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Formulario de reseña detallada - Próximamente'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryNormal,
          foregroundColor: AppColors.surface,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Reseñar Accesibilidad',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¿Qué te parece este lugar?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.neutralDarkDarker,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botón like (pulgar arriba)
            Container(
              decoration: BoxDecoration(
                color: AppColors.greenLight,
                borderRadius: BorderRadius.circular(50),
              ),
              child: IconButton(
                icon: const Icon(Icons.thumb_up_rounded),
                color: AppColors.greenNormal,
                iconSize: 32,
                padding: const EdgeInsets.all(16),
                onPressed: () {
                  // TODO: Enviar like al backend
                  debugPrint('Like enviado para: ${widget.placeDetails.placeId}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Gracias por tu opinión!'),
                      backgroundColor: AppColors.success,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 24),
            // Botón dislike (pulgar abajo)
            Container(
              decoration: BoxDecoration(
                color: AppColors.redLight,
                borderRadius: BorderRadius.circular(50),
              ),
              child: IconButton(
                icon: const Icon(Icons.thumb_down_rounded),
                color: AppColors.redNormal,
                iconSize: 32,
                padding: const EdgeInsets.all(16),
                onPressed: () {
                  // TODO: Enviar dislike al backend
                  debugPrint('Dislike enviado para: ${widget.placeDetails.placeId}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Gracias por tu opinión!'),
                      backgroundColor: AppColors.success,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
