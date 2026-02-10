import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/core/widgets/custom_filled_button.dart';
import 'package:inclusive_app/features/incidents/presentation/bloc/incident_type_bloc.dart';
import 'package:inclusive_app/features/incidents/presentation/bloc/incident_type_event.dart';
import 'package:inclusive_app/features/incidents/presentation/bloc/incident_type_state.dart';
import 'package:inclusive_app/features/incidents/presentation/constants/incident_subtypes.dart';
import 'package:inclusive_app/features/incidents/presentation/widgets/incident_item.dart';

class IncidentSubTypeSelector extends StatelessWidget {
  const IncidentSubTypeSelector({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncidentTypeBloc, IncidentTypeState>(
      builder: (context, state) {
        final subTypes = incidentSubTypes[state.selectedType]!;

        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomFilledButton(
                    label: 'Atrás',
                    isPrimary: false,
                    onPressed: () => context.read<IncidentTypeBloc>().add(
                      IncidentTypeGoBack(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomFilledButton(
                    label: 'Aceptar',
                    isPrimary: true,
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
        );
      },
    );
  }
}
