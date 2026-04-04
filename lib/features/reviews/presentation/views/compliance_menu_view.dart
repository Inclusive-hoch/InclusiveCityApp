import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_color.dart';
import '../../domain/entities/review_category.dart';
import '../bloc/review_bloc.dart';
import '../bloc/review_event.dart';
import '../widgets/review_option_tile.dart';
import '../../../../core/widgets/custom_filled_button.dart';
import '../bloc/review_state.dart';

class ComplianceMenuView extends StatelessWidget {
  final ScrollController scrollController;
  final String placeId;

  const ComplianceMenuView({
    super.key,
    required this.scrollController,
    required this.placeId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReviewBloc, ReviewState>(
      builder: (context, state) {
        final formsPayload = _buildFormsPayload(state);

        return Column(
          children: [
            // Contenido scrolleable
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                children: [
                  Text(
                    'Formulario de cumplimiento',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColor.secondaryNormal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Completa las preguntas y envia tu review.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColor.neutralDarkNormal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...ReviewCategory.values.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ReviewOptionTile(
                        title: category.label,
                        iconPath: category.iconPath,
                        onTap: () {
                          context.read<ReviewBloc>().add(
                            ReviewCategorySelected(category),
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            // Boton fijo abajo
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: CustomFilledButton(
                label: 'Enviar review',
                style: CustomButtonStyle.success,
                width: double.infinity,
                onPressed: state.isSubmitting
                    ? null
                    : () {
                        context.read<ReviewBloc>().add(
                          ReviewSubmitRequested(
                            placeId: placeId,
                            forms: formsPayload,
                          ),
                        );
                      },
              ),
            ),
          ],
        );
      },
    );
  }

  List<String> _buildFormsPayload(ReviewState state) {
    if (state.questions.isEmpty) {
      return List<String>.filled(6, 'NO');
    }

    final forms = state.questions
        .map((question) => question.answer == true ? 'YES' : 'NO')
        .toList();

    if (forms.length < 6) {
      forms.addAll(List<String>.filled(6 - forms.length, 'NO'));
    }

    if (forms.length > 6) {
      return forms.take(6).toList();
    }

    return forms;
  }
}
