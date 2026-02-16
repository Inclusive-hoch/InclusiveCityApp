import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_color.dart';
import '../../domain/entities/review_category.dart';
import '../bloc/review_bloc.dart';
import '../bloc/review_event.dart';
import '../widgets/review_option_tile.dart';
import '../../../../core/widgets/custom_filled_button.dart';

class ComplianceMenuView extends StatelessWidget {
  final ScrollController scrollController;

  const ComplianceMenuView({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
        ...ReviewCategory.values.map((category) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                ReviewOptionTile(
                  title: category.label,
                  iconPath: category.iconPath,
                  onTap: () {
                    context.read<ReviewBloc>().add(
                      ReviewCategorySelected(category),
                    );
                  },
                ),
              ],
            ),
          );
        }),
        const Divider(),
        const SizedBox(height: 16),
        CustomFilledButton(
          label: 'Finalizar el formulario',
          style: CustomButtonStyle.success,
          width: double.infinity,
          onPressed: () {
            context.read<ReviewBloc>().add(ReviewFinalizeRequested());
          },
        ),
      ],
    );
  }
}
