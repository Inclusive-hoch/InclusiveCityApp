import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/widgets/custom_filled_button.dart';
import '../bloc/review_bloc.dart';
import '../bloc/review_event.dart';
import '../bloc/review_state.dart';
import '../widgets/progress_dots.dart';

class AccessibilityFormView extends StatelessWidget {
  final ScrollController scrollController;

  const AccessibilityFormView({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReviewBloc, ReviewState>(
      builder: (context, state) {
        if (state.questions.isEmpty) return const SizedBox.shrink();

        final currentQuestion = state.questions[state.currentQuestionIndex];

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
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          context.read<ReviewBloc>().add(ReviewBackRequested());
                        },
                        icon: const Icon(Icons.arrow_back),
                        color: AppColor.primaryNormalActive,
                      ),
                      Expanded(
                        child: Text(
                          'Formulario de accesibilidad',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColor.primaryNormalActive,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ProgressDots(
                    totalSteps: state.questions.length,
                    currentStep: state.currentQuestionIndex,
                    stepsAnsweredState: state.questions
                        .map((q) => q.answer)
                        .toList(),
                    onPrevious: state.currentQuestionIndex > 0
                        ? () => context.read<ReviewBloc>().add(
                            ReviewBackRequested(),
                          )
                        : null,
                    onNext:
                        state.currentQuestionIndex < state.questions.length - 1
                        ? () => context.read<ReviewBloc>().add(
                            ReviewNextRequested(),
                          )
                        : null,
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColor.primaryLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      currentQuestion.question,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColor.neutralDarkNormal,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Botones fijos abajo
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomFilledButton(
                    label: 'Si cumple',
                    style: CustomButtonStyle.success,
                    icon: Icons.check,
                    width: double.infinity,
                    onPressed: () {
                      context.read<ReviewBloc>().add(
                        ReviewQuestionAnswered(currentQuestion.id, true),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomFilledButton(
                    label: 'No cumple',
                    style: CustomButtonStyle.error,
                    icon: Icons.close,
                    width: double.infinity,
                    onPressed: () {
                      context.read<ReviewBloc>().add(
                        ReviewQuestionAnswered(currentQuestion.id, false),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
