import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/places/presentation/widget/photo_gallery.dart';
import 'package:inclusive_app/features/places/presentation/widget/raiting.dart';
import 'package:inclusive_app/features/places/presentation/widget/medals.dart';
import 'package:inclusive_app/features/places/presentation/widget/feedback.dart'
    as place_feedback;
import 'package:inclusive_app/shared/widgets/grabber.dart';
import 'package:inclusive_app/features/map_view/presentation/bloc/map_bloc.dart'
    as map_bloc;
import 'package:inclusive_app/features/places/presentation/bloc/place_bloc.dart'
  as place_bloc;
import 'package:inclusive_app/core/auth/firebase_auth_service.dart';
import 'package:inclusive_app/injection_container.dart' as di;
import 'package:inclusive_app/features/reviews/domain/usecases/save_place_rate_choice_usecase.dart';
import 'package:inclusive_app/features/reviews/presentation/views/review_container.dart';
import 'package:inclusive_app/features/spot/presentation/bloc/spot_bloc.dart';
import 'package:inclusive_app/features/spot/presentation/widgets/list_selector_bottom_sheet.dart';

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
  bool _isSubmittingRate = false;
  String _authToken = '';
  String? _selectedRateChoice;
  late String _placeName;
  late String _address;
  late List<String> _photoReferences;
  late List<String> _medals;
  late double _rating;
  late double _latitude;
  late double _longitude;

  @override
  void initState() {
    super.initState();
    _placeName = widget.placeName;
    _address = widget.address;
    _photoReferences = List<String>.from(widget.photoReferences);
    _medals = List<String>.from(widget.medals);
    _rating = widget.rating;
    _latitude = widget.latitude;
    _longitude = widget.longitude;
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

  /// Muestra el bottom sheet para seleccionar o crear lista
  void _showListSelectorBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<SpotBloc>(),
        child: ListSelectorBottomSheet(
          placeId: widget.placeId,
          placeName: _placeName,
          address: _address,
          latitude: _latitude,
          longitude: _longitude,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SpotBloc, SpotState>(
      listener: (context, state) {
        if (state is SpotCreated || state is CustomSpotCreated) {
          setState(() {
            isSaved = true;
          });
        }
      },
      child: Container(
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
                          _placeName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      // Botones de acción inline
                      IconButton(
                        onPressed: _showListSelectorBottomSheet,
                        icon: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: AppColor.primaryNormal,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: Implementar compartir
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
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(children: [Rating(rating: _rating)]),
                ),
                const SizedBox(height: 12),

                // Medallas de accesibilidad
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: AccessibilityMedalsSection(medals: _medals),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  height: 200,
                  child: _authToken.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColor.primaryNormal,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: PhotoGallery(
                            photoReferences: _photoReferences,
                            authToken: _authToken,
                          ),
                        ),
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
                          _address,
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
                        _showReviewModal(
                          context,
                          rateChoice: _selectedRateChoice ?? 'DISLIKE',
                        );
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
                      _confirmAndSubmitRateChoice('LIKE');
                    },
                    onDislike: () {
                      _confirmAndSubmitRateChoice('DISLIKE');
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
            if (_isSubmittingRate)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x66000000),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColor.primaryNormal,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndSubmitRateChoice(String rateChoice) async {
    final isLike = rateChoice == 'LIKE';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isLike ? 'Confirmar me gusta' : 'Confirmar no me gusta'),
          content: Text(
            isLike
                ? 'Se enviara tu calificacion de me gusta para este lugar. Deseas continuar?'
                : 'Se enviara tu calificacion de no me gusta para este lugar. Deseas continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isSubmittingRate = true;
    });

    final savePlaceRateChoiceUseCase = di.sl<SavePlaceRateChoiceUseCase>();
    final result = await savePlaceRateChoiceUseCase(
      SavePlaceRateChoiceParams(
        placeId: widget.placeId,
        rateChoice: rateChoice,
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmittingRate = false;
    });

    await result.fold(
      (failure) async {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) async {
        if (!mounted) return;
        setState(() {
          _selectedRateChoice = rateChoice;
        });
        await _refreshPlaceDetails();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              rateChoice == 'LIKE'
                  ? 'Se envio tu me gusta correctamente.'
                  : 'Se envio tu no me gusta correctamente.',
            ),
            backgroundColor: AppColor.greenNormal,
          ),
        );
      },
    );
  }

  /// Genera la ruta desde la ubicación del usuario hasta este lugar
  void _onGenerateRoute(BuildContext context) async {
    // Obtener el estado actual del MapBloc para conseguir la ubicación del usuario
    final mapBloc = context.read<map_bloc.MapBloc>();
    final mapState = mapBloc.state;

    // Si ya tenemos la ubicación, navegar directamente
    if (mapState is map_bloc.MapLocationLoaded) {
      _navigateToRoute(context, mapState.latitude, mapState.longitude);
      return;
    }

    // Si no tenemos ubicación, intentar obtenerla
    // Mostrar indicador de carga
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColor.primaryNormal),
      ),
    );

    // Disparar el evento para obtener la ubicación
    mapBloc.add(map_bloc.GetUserLocationEvent());

    // Esperar el resultado con timeout para evitar espera indefinida
    try {
      final resultState = await mapBloc.stream
          .firstWhere(
            (s) => s is map_bloc.MapLocationLoaded || s is map_bloc.MapError,
          )
          .timeout(const Duration(seconds: 15));

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Cerrar diálogo de carga

      if (resultState is map_bloc.MapLocationLoaded) {
        _navigateToRoute(context, resultState.latitude, resultState.longitude);
      } else if (resultState is map_bloc.MapError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultState.message),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Configuración',
              textColor: Colors.white,
              onPressed: () => Geolocator.openLocationSettings(),
            ),
          ),
        );
      }
    } on TimeoutException {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener la ubicación. Verifica tu GPS.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Navega a la pantalla de selección de ruta
  void _navigateToRoute(BuildContext context, double userLat, double userLng) {
    // Cerrar el modal de detalles del lugar
    Navigator.pop(context);

    // Navegar a la pantalla de selección de ruta
    context.push(
      '/route-selection',
      extra: {
        'originLat': userLat,
        'originLng': userLng,
        'destLat': _latitude,
        'destLng': _longitude,
        'originName': 'Mi ubicación',
        'destName': _placeName,
      },
    );
  }

  /// Abre el modal de reseña de accesibilidad
  Future<void> _showReviewModal(
    BuildContext context, {
    required String rateChoice,
  }) async {
    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReviewContainer(
        placeId: widget.placeId,
        rateChoice: rateChoice,
      ),
    );

    if (submitted == true) {
      await _refreshPlaceDetails();
    }
  }

  Future<void> _refreshPlaceDetails() async {
    final bloc = context.read<place_bloc.PlaceBloc>();
    bloc.add(place_bloc.FetchPlaceDetailsEvent(widget.placeId));

    try {
      final resultState = await bloc.stream
          .firstWhere(
            (state) =>
                state is place_bloc.PlaceDetailsFetched &&
                state.placeDetails.placeId == widget.placeId,
          )
          .timeout(const Duration(seconds: 12));

      if (!mounted || resultState is! place_bloc.PlaceDetailsFetched) return;

      final details = resultState.placeDetails;
      setState(() {
        _placeName = details.name;
        _address = details.address;
        _photoReferences = List<String>.from(details.photos);
        _medals = List<String>.from(details.medals);
        _rating = details.rating;
        _latitude = details.latitude;
        _longitude = details.longitude;
      });
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La review se envio, pero no se pudo refrescar el detalle del lugar.',
          ),
        ),
      );
    }
  }
}
