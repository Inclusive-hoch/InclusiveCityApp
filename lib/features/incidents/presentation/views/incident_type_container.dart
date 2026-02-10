import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/core/widgets/custom_filled_button.dart';
import 'package:inclusive_app/features/incidents/presentation/widgets/incident_item.dart';
import 'package:inclusive_app/features/incidents/presentation/bloc/incident_type_bloc.dart';
import 'package:inclusive_app/features/incidents/presentation/bloc/incident_type_event.dart';
import 'package:inclusive_app/features/incidents/presentation/bloc/incident_type_state.dart';
import 'package:inclusive_app/features/incidents/presentation/views/incident_report.dart';

class IncidentTypeContainer extends StatelessWidget {
  const IncidentTypeContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => IncidentTypeBloc(),
      child: DraggableScrollableSheet(
        initialChildSize: 0.29,
        minChildSize: 0.25,
        maxChildSize: 0.5,
        builder: (draggableContext, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: AppColor.neutralLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '¿Ocurre algo en el camino?',
                          style: TextStyle(
                            color: AppColor.primaryNormalActive,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      BlocBuilder<IncidentTypeBloc, IncidentTypeState>(
                        builder: (context, state) {
                          return IconButton(
                            icon: Icon(
                              size: 32,
                              Icons.close,
                              color: AppColor.primaryNormalActive,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              // Reset after closing to avoid showing first questionnaire
                              Future.microtask(() {
                                context.read<IncidentTypeBloc>().add(
                                  IncidentTypeReset(),
                                );
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: BlocConsumer<IncidentTypeBloc, IncidentTypeState>(
                    listener: (context, state) {
                      if (state.hasType && state.hasSubType) {
                        debugPrint(
                          'Tipo: ${state.selectedType} | Subtipo: ${state.selectedSubType}',
                        );
                        // Close modal after current frame to avoid UI flicker
                        Future.microtask(() => Navigator.of(context).pop());
                      }
                    },
                    builder: (context, state) {
                      if (!state.hasType) {
                        return ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          children: [
                            Wrap(
                              direction: Axis.horizontal,
                              spacing: 16,
                              runSpacing: 16,
                              alignment: WrapAlignment.spaceAround,
                              children: [
                                IncidentItem(
                                  icon: Icons.accessible_forward_outlined,
                                  title: 'Transporte',
                                  isSelected:
                                      state.temporaryType == 'Transporte',
                                  onTap: () =>
                                      context.read<IncidentTypeBloc>().add(
                                        const IncidentTypeTemporarilySelected(
                                          'Transporte',
                                        ),
                                      ),
                                ),
                                IncidentItem(
                                  icon: Icons.accessibility_new_sharp,
                                  title: 'Accesibilidad',
                                  isSelected:
                                      state.temporaryType == 'Accesibilidad',
                                  onTap: () =>
                                      context.read<IncidentTypeBloc>().add(
                                        const IncidentTypeTemporarilySelected(
                                          'Accesibilidad',
                                        ),
                                      ),
                                ),
                                IncidentItem(
                                  icon: Icons.wheelchair_pickup_outlined,
                                  title: 'Movilidad',
                                  isSelected:
                                      state.temporaryType == 'Movilidad',
                                  onTap: () =>
                                      context.read<IncidentTypeBloc>().add(
                                        const IncidentTypeTemporarilySelected(
                                          'Movilidad',
                                        ),
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: CustomFilledButton(
                                    label: 'Atrás',
                                    isPrimary: false,
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Future.microtask(() {
                                        context.read<IncidentTypeBloc>().add(
                                          IncidentTypeReset(),
                                        );
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomFilledButton(
                                    label: 'Siguiente',
                                    isPrimary: true,
                                    onPressed: state.hasTemporaryType
                                        ? () => context
                                              .read<IncidentTypeBloc>()
                                              .add(IncidentTypeConfirmed())
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }

                      return IncidentSubTypeSelector(
                        scrollController: scrollController,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
