import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/widgets/custom_filled_button.dart';

class ReviewSuccessView extends StatelessWidget {
  final ScrollController scrollController;
  final VoidCallback onFinish;

  const ReviewSuccessView({
    super.key,
    required this.scrollController,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      children: [
        const Icon(
          Icons.check_circle_outline_rounded,
          size: 80,
          color: AppColor.greenNormal,
        ),
        const SizedBox(height: 24),
        const Text(
          'Gracias por realizar el formulario',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 48),
        CustomFilledButton(
          label: 'Finalizar',
          style: CustomButtonStyle.primary,
          onPressed: onFinish,
        ),
      ],
    );
  }
}
