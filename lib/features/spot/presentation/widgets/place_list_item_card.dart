import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/spot/domain/entities/spot.dart';
import 'package:inclusive_app/features/places/presentation/bloc/place_bloc.dart';
import 'package:inclusive_app/core/constants/api_constants.dart';

/// Tarjeta que muestra un lugar dentro de una lista personalizada.
/// 
/// Incluye imagen, nombre, rating y medallas de accesibilidad.
class PlaceListItemCard extends StatefulWidget {
  final Spot spot;
  final Function({
    required List<String> photoReferences,
    required double rating,
    required List<String> medals,
  }) onTap;
  final VoidCallback onDelete;

  const PlaceListItemCard({
    super.key,
    required this.spot,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<PlaceListItemCard> createState() => _PlaceListItemCardState();
}

class _PlaceListItemCardState extends State<PlaceListItemCard> {
  String? _photoUrl;
  List<String>? _photoReferences;
  double? _rating;
  List<String>? _medals;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaceDetails();
  }

  void _loadPlaceDetails() {
    context.read<PlaceBloc>().add(FetchPlaceDetailsEvent(widget.spot.placeId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlaceBloc, PlacesState>(
      listener: (context, state) {
        if (state is PlaceDetailsFetched && state.placeDetails.placeId == widget.spot.placeId) {
          setState(() {
            _rating = state.placeDetails.rating;
            _medals = state.placeDetails.medals;
            _photoReferences = state.placeDetails.photos;
            if (state.placeDetails.photos.isNotEmpty) {
              _photoUrl = ApiConstants.placePhoto(state.placeDetails.photos.first);
            }
            _isLoading = false;
          });
        } else if (state is PlacesError) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: !_isLoading && _photoReferences != null && _rating != null && _medals != null
              ? () => widget.onTap(
                    photoReferences: _photoReferences ?? [],
                    rating: _rating ?? 0.0,
                    medals: _medals ?? [],
                  )
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información del lugar (arriba)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del lugar
                    Text(
                      widget.spot.spotName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Rating
                    if (_rating != null && _rating! > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.thumb_up,
                            size: 16,
                            color: AppColor.primaryNormal,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Al ${_rating!.toInt()}% le gusta este lugar',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColor.primaryNormal,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Medallas de accesibilidad
                    if (_medals != null && _medals!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: _medals!.take(3).map((medal) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: _buildAccessibilityIcon(medal),
                          );
                        }).toList(),
                      ),
                    ],

                    // Loading indicator
                    if (_isLoading) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColor.primaryNormal,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Imagen del lugar con dirección en overlay
              if (_photoUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Image.network(
                        _photoUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder();
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _buildPlaceholder();
                        },
                      ),
                      // Overlay con dirección
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.75),
                              ],
                            ),
                          ),
                          child: Text(
                            widget.spot.address,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (_isLoading)
                _buildPlaceholder()
              else
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Sin imagen disponible',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Dirección en la parte inferior
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                          ),
                          child: Text(
                            widget.spot.address,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColor.primaryNormal,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildAccessibilityIcon(String medal) {
    IconData icon;
    Color color;

    switch (medal.toLowerCase()) {
      case 'wheelchair':
      case 'accesible':
      case 'rampa':
      case 'silla de ruedas':
        icon = Icons.accessible;
        color = const Color(0xFF4B7BEC);
        break;
      case 'parking':
      case 'estacionamiento':
        icon = Icons.local_parking;
        color = const Color(0xFF4B7BEC);
        break;
      case 'elevator':
      case 'ascensor':
        icon = Icons.elevator;
        color = const Color(0xFF4B7BEC);
        break;
      case 'bathroom':
      case 'baño':
      case 'baño accesible':
        icon = Icons.wc;
        color = const Color(0xFF4B7BEC);
        break;
      case 'braille':
        icon = Icons.text_fields;
        color = const Color(0xFF4B7BEC);
        break;
      default:
        icon = Icons.check_circle;
        color = const Color(0xFF4B7BEC);
    }

    return Icon(
      icon,
      size: 32,
      color: color,
    );
  }
}
