import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_color.dart';
import '../bloc/review_bloc.dart';
import '../bloc/review_state.dart';
import 'compliance_menu_view.dart';
import 'accessibility_form_view.dart';
import 'review_success_view.dart';

class ReviewContainer extends StatefulWidget {
  const ReviewContainer({super.key});

  @override
  State<ReviewContainer> createState() => _ReviewContainerState();
}

class _ReviewContainerState extends State<ReviewContainer> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReviewBloc(),
      child: DraggableScrollableSheet(
        controller: _sheetController,
        initialChildSize: 0.8,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (draggableContext, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: AppColor.neutralLight,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Barra superior de arrastre
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColor.neutralNormalHover,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Expanded(
                  child: BlocConsumer<ReviewBloc, ReviewState>(
                    listener: (context, state) {
                      // Ajustar altura según el estado si es necesario
                      if (state.step == ReviewStep.form) {
                        _animateTo(0.65);
                      } else if (state.step == ReviewStep.success) {
                        _animateTo(0.5);
                      }
                    },
                    builder: (context, state) {
                      switch (state.step) {
                        case ReviewStep.menu:
                          return ComplianceMenuView(
                            scrollController: scrollController,
                          );
                        case ReviewStep.form:
                          return AccessibilityFormView(
                            scrollController: scrollController,
                          );
                        case ReviewStep.success:
                          return ReviewSuccessView(
                            scrollController: scrollController,
                            onFinish: () {
                              Navigator.of(context).pop();
                            },
                          );
                      }
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

  void _animateTo(double extent) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_sheetController.isAttached) {
        _sheetController.animateTo(
          extent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }
}
