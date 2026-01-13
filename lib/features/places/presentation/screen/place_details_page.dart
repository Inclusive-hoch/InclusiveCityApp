import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/places/presentation/widget/photo_gallery.dart';
import 'package:inclusive_app/features/places/presentation/widget/header_actions.dart';
import 'package:inclusive_app/features/places/presentation/widget/raiting.dart';
import 'package:inclusive_app/features/places/presentation/widget/medals.dart';
import 'package:inclusive_app/features/places/presentation/widget/feedback.dart' as place_feedback;
import 'package:inclusive_app/shared/widgets/grabber.dart';

/// Página de detalles de un lugar con información de accesibilidad
/// 
/// Panel deslizable que muestra información completa del lugar.
/// Se puede deslizar hacia abajo para cerrar.
class PlaceDetailsPage extends StatefulWidget {
  /// ID del lugar a mostrar
  final String placeId;
  
  /// Nombre del lugar
  final String placeName;
  
  /// Dirección del lugar
  final String address;
  
  /// Referencias de las fotos del lugar
  final List<String> photoReferences;
  
  /// Calificación del lugar (0-100)
  final double rating;
  
  /// Lista de medallas de accesibilidad
  final List<String> medals;

  const PlaceDetailsPage({
    super.key,
    required this.placeId,
    required this.placeName,
    required this.address,
    required this.photoReferences,
    required this.rating,
    required this.medals,
  });

  @override
  State<PlaceDetailsPage> createState() => _PlaceDetailsPageState();
}

class _PlaceDetailsPageState extends State<PlaceDetailsPage> {
  bool isSaved = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Stack(
        children: [
          // Contenido principal con scroll
          ListView(
            padding: EdgeInsets.zero,
            children: [
              // Grabber para indicar que es deslizable
              const Center(child: Grabber()),
              const SizedBox(height: 8),
              
              // Header con título y botones de acción
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.placeName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    // Botones de acción inline
                    IconButton(
                      onPressed: () {
                        setState(() => isSaved = !isSaved);
                      },
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: AppColor.primaryNormal,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // TODO: Implementar compartir
                        print('Compartir lugar');
                      },
                      icon: const Icon(
                        Icons.share,
                        color: AppColor.primaryNormal,
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
              const SizedBox(height: 12),
              
              // Rating y medallas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Rating(rating: widget.rating),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Medallas de accesibilidad
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: AccessibilityMedalsSection(medals: widget.medals),
              ),
              const SizedBox(height: 16),
              
              // Botones de ruta
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Generar ruta
                          print('Generar ruta');
                        },
                        icon: const Icon(Icons.route, size: 20),
                        label: const Text('Generar ruta'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryNormal,
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
                          // TODO: Iniciar navegación
                          print('Iniciar ruta');
                        },
                        icon: const Icon(Icons.navigation, size: 20),
                        label: const Text('Iniciar ruta'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColor.primaryNormal,
                          side: BorderSide(color: AppColor.primaryNormal),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Galería de fotos
              SizedBox(
                height: 250,
                child: PhotoGallery(
                  photoReferences: widget.photoReferences,
                ),
              ),
              const SizedBox(height: 16),
              
              // Dirección
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.address,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Botón de reseñar accesibilidad
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Navegar a la página de reseña
                      print('Reseñar Accesibilidad');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryNormal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Reseñar Accesibilidad',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Pregunta de feedback
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: place_feedback.Feedback(
                  placeId: widget.placeId,
                  onLike: () {
                    // TODO: Implementar lógica de "me gusta"
                    print('Like pressed');
                  },
                  onDislike: () {
                    // TODO: Implementar lógica de "no me gusta"
                    print('Dislike pressed');
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ],
      ),
    );
  }
}
