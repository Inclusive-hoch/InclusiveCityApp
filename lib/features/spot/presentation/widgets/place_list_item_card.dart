import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/spot/domain/entities/spot.dart';
import 'package:inclusive_app/features/places/presentation/bloc/place_bloc.dart';
import 'package:inclusive_app/core/constants/api_constants.dart';
import 'package:inclusive_app/core/utils/accessibility_medals.dart';

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
      child: InkWell(
        onTap: !_isLoading && _photoReferences != null && _rating != null && _medals != null
            ? () => widget.onTap(
                  photoReferences: _photoReferences ?? [],
                  rating: _rating ?? 0.0,
                  medals: _medals ?? [],
                )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre + botón eliminar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.spot.spotName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                    onPressed: widget.onDelete,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Rating
            if (_rating != null && _rating! > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Row(
                  children: [
                    Icon(Icons.thumb_up, size: 18, color: AppColor.primaryNormal),
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
              ),

            // Loading
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColor.primaryNormal),
                ),
              ),

            // Medallas de accesibilidad
            if (_medals != null && _medals!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: _medals!.take(3).map((medal) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _buildAccessibilityIcon(medal),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 12),

            // Foto
            if (_photoUrl != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _photoUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPhotoPlaceholder(),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildPhotoPlaceholder();
                    },
                  ),
                ),
              )
            else if (_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildPhotoPlaceholder(),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 160,
                    color: Colors.grey[100],
                    child: Center(
                      child: Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.grey[400]),
                    ),
                  ),
                ),
              ),

            // Dirección
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, size: 15, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.spot.address,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Container(
      height: 180,
      color: Colors.grey[200],
      child: Center(
        child: CircularProgressIndicator(
          color: AppColor.primaryNormal,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildAccessibilityIcon(String medal) {
    // Resuelve la medalla usando el helper canónico (igual que places/widget/medals.dart)
    final resolvedMedal = AccessibilityMedalsHelper.fromApiName(medal);

    final Widget iconWidget = resolvedMedal != null
        ? Icon(resolvedMedal.icon, size: 22, color: Colors.white)
        : const Icon(Icons.check_circle_outline, size: 22, color: Colors.white);

    return Tooltip(
      message: resolvedMedal?.displayName ?? medal,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF4B7BEC),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: iconWidget),
      ),
    );
  }
}
