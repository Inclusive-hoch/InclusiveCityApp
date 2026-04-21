import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/core/widgets/custom_filled_button.dart';
import 'package:inclusive_app/features/incidents/presentation/bloc/incident_type_bloc.dart';
import 'package:inclusive_app/features/incidents/presentation/bloc/incident_type_event.dart';
import 'package:inclusive_app/features/incidents/presentation/bloc/incident_type_state.dart';
import 'package:inclusive_app/features/incidents/presentation/constants/incident_subtypes.dart';
import 'package:inclusive_app/features/incidents/presentation/widgets/incident_item.dart';

class IncidentSubTypeSelector extends StatelessWidget {
  const IncidentSubTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncidentTypeBloc, IncidentTypeState>(
      builder: (context, state) {
        final subTypes = incidentSubTypes[state.selectedType]!;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                direction: Axis.horizontal,
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.spaceAround,
                children: subTypes
                    .map(
                      (sub) => IncidentItem(
                        icon: sub.icon,
                        title: sub.name,
                        isSelected: state.temporarySubType == sub.name,
                        onTap: () => context.read<IncidentTypeBloc>().add(
                          IncidentSubTypeTemporarilySelected(sub.name),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CustomFilledButton(
                      label: 'Atrás',
                      style: CustomButtonStyle.secondary,
                      onPressed: () => context.read<IncidentTypeBloc>().add(
                        IncidentTypeGoBack(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomFilledButton(
                      label: 'Aceptar',
                      style: CustomButtonStyle.primary,
                      onPressed: state.hasTemporarySubType
                          ? () => context.read<IncidentTypeBloc>().add(
                              IncidentSubTypeConfirmed(),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
