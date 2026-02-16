import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';

class ProgressDots extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  /// Lista que indica si cada paso fue respondido.
  /// null = no respondido, true/false = respondido.
  final List<bool?> stepsAnsweredState;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const ProgressDots({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    required this.stepsAnsweredState,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
          color: onPrevious != null
              ? AppColor.primaryNormal
              : AppColor.neutralNormalHover,
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(totalSteps, (index) {
            final isCurrent = index == currentStep;
            final isAnswered = stepsAnsweredState[index] != null;
            final isPassed = index < currentStep;

            Color dotColor;
            if (isCurrent) {
              dotColor = AppColor.primaryNormal;
            } else if (isAnswered) {
              dotColor = AppColor.success;
            } else if (isPassed) {
              dotColor = AppColor.error;
            } else {
              dotColor = AppColor.neutralNormalHover;
            }

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
                border: isCurrent
                    ? Border.all(color: AppColor.primaryNormalActive, width: 2)
                    : null,
              ),
              child: isCurrent
                  ? Center(
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            );
          }),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
          color: onNext != null
              ? AppColor.primaryNormal
              : AppColor.neutralNormalHover,
        ),
      ],
    );
  }
}
