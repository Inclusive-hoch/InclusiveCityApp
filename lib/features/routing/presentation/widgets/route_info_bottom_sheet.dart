import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/routing/application/bloc/route_bloc.dart';

/// Panel inferior que muestra información de la ruta y botón de cancelar
class RouteInfoBottomSheet extends StatelessWidget {
  final String originName;
  final String destName;
  final VoidCallback onCancel;

  const RouteInfoBottomSheet({
    super.key,
    required this.originName,
    required this.destName,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: BlocBuilder<RouteBloc, RouteState>(
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Información de la ruta
                    if (state is RouteLoaded && state.alternativeRoute != null)
                      _buildRouteInfo(state, context),
                    
                    // Indicador de carga
                    if (state is RouteLoading)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 24.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    
                    // Botón Cancelar
                    _buildCancelButton(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRouteInfo(RouteLoaded state, BuildContext context) {
    final duration = state.alternativeRoute!.formattedDuration;
    final isLongDuration = duration.contains('hora');
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Duración
          if (isLongDuration)
            _buildMultiLineDuration(duration)
          else
            Text(
              duration,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
          const SizedBox(width: 20),

          // Información de distancia y ruta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.alternativeRoute!.formattedDistance,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Por ${originName.split(',').first}, ${destName.split(',').first}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ruta segura, sin incidencias',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiLineDuration(String duration) {
    // Divide la duración en líneas cuando contiene horas
    // Ejemplo: "20 horas 26 min" -> "20 horas" + "26 min"
    final parts = duration.split(' ');
    
    if (parts.length >= 4) {
      // Formato: "X hora(s) Y min"
      final hoursPart = '${parts[0]} ${parts[1]}';
      final minutesPart = '${parts[2]} ${parts[3]}';
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hoursPart,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          Text(
            minutesPart,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
        ],
      );
    } else {
      // Formato solo horas: "X hora(s)"
      return Text(
        duration,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: Colors.black87,
          letterSpacing: -0.5,
        ),
      );
    }
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onCancel,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryNormal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: AppColor.primaryNormal.withValues(alpha: 0.3),
        ),
        child: const Text(
          'Cancelar',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
