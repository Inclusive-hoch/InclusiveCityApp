import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/core/constants/api_constants.dart';

/// Galería de fotos con navegación por páginas.
/// 
/// Muestra una lista de fotos en formato carrusel con indicadores
/// de posición. Carga las imágenes desde el backend usando las
/// referencias de fotos proporcionadas.
class PhotoGallery extends StatefulWidget {
  /// Lista de referencias de fotos del lugar.
  final List<String> photoReferences;

  const PhotoGallery({
    super.key,
    required this.photoReferences,
  });

  @override
  State<PhotoGallery> createState() => _PlacePhotoGalleryState();
}

class _PlacePhotoGalleryState extends State<PhotoGallery> {
  int _selectedPhotoIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.photoReferences.isEmpty) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 200,
        child: Stack(
          children: [
            _buildPageView(),
            if (widget.photoReferences.length > 1) _buildPageIndicator(),
          ],
        ),
      ),
    );
  }

  /// Construye el PageView con las fotos.
  Widget _buildPageView() {
    return PageView.builder(
      itemCount: widget.photoReferences.length,
      onPageChanged: (index) {
        setState(() {
          _selectedPhotoIndex = index;
        });
      },
      itemBuilder: (context, index) {
        final photoUrl = ApiConstants.placePhoto(widget.photoReferences[index]);
        return _buildPhotoItem(photoUrl);
      },
    );
  }

  /// Construye un item de foto individual con estados de carga y error.
  Widget _buildPhotoItem(String photoUrl) {
    return Image.network(
      photoUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoadingIndicator(loadingProgress);
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorPlaceholder();
      },
    );
  }

  /// Indicador de carga mientras se descarga la imagen.
  Widget _buildLoadingIndicator(ImageChunkEvent loadingProgress) {
    return Container(
      color: AppColor.neutralLight,
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
  }

  /// Placeholder cuando falla la carga de la imagen.
  Widget _buildErrorPlaceholder() {
    return Container(
      color: AppColor.neutralLight,
      child: const Center(
        child: Icon(
          Icons.broken_image,
          size: 50,
          color: AppColor.neutralDarkNormal,
        ),
      ),
    );
  }

  /// Indicador de páginas (puntos en la parte inferior).
  Widget _buildPageIndicator() {
    return Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.photoReferences.length,
          (index) => _buildDot(index),
        ),
      ),
    );
  }

  /// Construye un punto indicador individual.
  Widget _buildDot(int index) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _selectedPhotoIndex == index
            ? AppColor.primaryNormal
            : AppColor.surface.withOpacity(0.5),
      ),
    );
  }
}