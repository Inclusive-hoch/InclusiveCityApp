import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/places/presentation/widget/photo_gallery.dart';
import 'package:inclusive_app/features/places/presentation/widget/raiting.dart';
import 'package:inclusive_app/features/places/presentation/widget/medals.dart';
import 'package:inclusive_app/features/places/presentation/widget/feedback.dart'
    as place_feedback;
import 'package:inclusive_app/shared/widgets/grabber.dart';
import 'package:inclusive_app/features/map_view/presentation/bloc/map_bloc.dart' as map_bloc;
import 'package:inclusive_app/core/auth/firebase_auth_service.dart';
import 'package:inclusive_app/injection_container.dart' as di;
import 'package:inclusive_app/features/reviews/presentation/views/review_container.dart';

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

  /// Latitud del lugar
  final double latitude;

  /// Longitud del lugar
  final double longitude;

  const PlaceDetailsPage({
    super.key,
    required this.placeId,
    required this.placeName,
    required this.address,
    required this.photoReferences,
    required this.rating,
    required this.medals,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<PlaceDetailsPage> createState() => _PlaceDetailsPageState();
}

class _PlaceDetailsPageState extends State<PlaceDetailsPage> {
  bool isSaved = false;
  String _authToken = '';

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
  }

  /// Carga el token de autenticación para las fotos.
  Future<void> _loadAuthToken() async {
    final token = await di.sl<FirebaseAuthService>().getIdToken();
    if (mounted) {
      setState(() {
        _authToken = token;
      });
    }
  }

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
                child: Row(children: [Rating(rating: widget.rating)]),
              ),
              const SizedBox(height: 12),

              // Medallas de accesibilidad
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: AccessibilityMedalsSection(medals: widget.medals),
              ),
              const SizedBox(height: 16),

              // Botón de ruta
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _onGenerateRoute(context),
                    icon: const Icon(Icons.route, size: 20),
                    label: const Text('Generar ruta'),
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
              ),
              const SizedBox(height: 16),

              // Galería de fotos
              SizedBox(
                height: 250,
                child: _authToken.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColor.primaryNormal,
                        ),
                      )
                    : PhotoGallery(
                        photoReferences: widget.photoReferences,
                        authToken: _authToken,
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
                    onPressed: () => _showReviewModal(context),
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

  /// Genera la ruta desde la ubicación del usuario hasta este lugar
  void _onGenerateRoute(BuildContext context) {
    // Obtener el estado actual del MapBloc para conseguir la ubicación del usuario
    final mapState = context.read<map_bloc.MapBloc>().state;

    if (mapState is map_bloc.MapLocationLoaded) {
      // Cerrar el modal de detalles del lugar
      Navigator.pop(context);

      // Navegar a la pantalla de selección de ruta
      context.push(
        '/route-selection',
        extra: {
          'originLat': mapState.latitude,
          'originLng': mapState.longitude,
          'destLat': widget.latitude,
          'destLng': widget.longitude,
          'originName': 'Mi ubicación',
          'destName': widget.placeName,
        },
      );
    } else {
      // No tenemos ubicación del usuario, mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo obtener tu ubicación. Activa el GPS e intenta de nuevo.',
          ),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Abre el modal de reseña de accesibilidad
  void _showReviewModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ReviewContainer(),
    );
  }
}
