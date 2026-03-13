import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/core/widgets/custom_filled_button.dart';
import 'package:inclusive_app/features/incidents/presentation/bloc/incident_type_bloc.dart';
import 'package:inclusive_app/features/incidents/presentation/pages/incident_camera_page.dart';
import 'package:inclusive_app/features/incidents/presentation/bloc/incident_type_event.dart';

/// Paso 3: Pregunta al usuario si desea agregar una foto de la incidencia.
class IncidentPhotoPrompt extends StatelessWidget {
  final ScrollController scrollController;
  final VoidCallback onSkip;
  final ValueChanged<String> onPhotoAccepted;
  final VoidCallback onCancel;

  const IncidentPhotoPrompt({
    super.key,
    required this.scrollController,
    required this.onSkip,
    required this.onPhotoAccepted,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 16),
        Icon(
          Icons.camera_alt_rounded,
          size: 64,
          color: AppColor.primaryNormalActive,
        ),
        const SizedBox(height: 16),
        Text(
          '¿Desea agregar una fotografía\nde la incidencia?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColor.primaryNormalActive,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '(Opcional)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColor.neutralDark),
        ),
        const SizedBox(height: 24),

        // Botones Omitir / Tomar Foto
        Row(
          children: [
            Expanded(
              child: CustomFilledButton(
                label: 'Omitir',
                style: CustomButtonStyle.secondary,
                onPressed: () {
                  context.read<IncidentTypeBloc>().add(IncidentPhotoSkipped());
                  onSkip();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomFilledButton(
                label: 'Tomar Foto',
                style: CustomButtonStyle.primary,
                onPressed: () {
                  Navigator.of(context)
                      .push<String?>(
                        MaterialPageRoute(
                          builder: (_) => const IncidentCameraPage(),
                        ),
                      )
                      .then((photoPath) {
                        if (!context.mounted) return;

                        if (photoPath != null) {
                          // Foto aceptada → guardar en Bloc, log y cerrar modal
                          context.read<IncidentTypeBloc>().add(
                            IncidentPhotoCaptured(photoPath),
                          );
                          debugPrint('Incidencia con foto — Path: $photoPath');
                          onPhotoAccepted(photoPath);
                        } else {
                          // Cancelado desde cámara → resetear y cerrar modal
                          context.read<IncidentTypeBloc>().add(
                            IncidentTypeReset(),
                          );
                          onCancel();
                        }
                      });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Cancelar registro
        Center(
          child: TextButton(
            onPressed: () {
              context.read<IncidentTypeBloc>().add(IncidentTypeReset());
              onCancel();
            },
            child: Text(
              'Cancelar registro',
              style: TextStyle(
                color: AppColor.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
