import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../injection_container.dart' as di;
import '../bloc/review_bloc.dart';
import '../bloc/review_event.dart';
import '../bloc/review_state.dart';
import 'compliance_menu_view.dart';
import 'accessibility_form_view.dart';
import 'review_success_view.dart';

class ReviewContainer extends StatefulWidget {
  final String placeId;
  final String rateChoice;

  const ReviewContainer({
    super.key,
    required this.placeId,
    required this.rateChoice,
  });

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
      create: (_) => di.sl<ReviewBloc>()
        ..add(ReviewRateChoiceChanged(widget.rateChoice)),
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
                    listenWhen: (previous, current) =>
                        previous.submissionStatus != current.submissionStatus,
                    listener: (context, state) {
                      // Ajustar altura según el estado si es necesario
                      if (state.step == ReviewStep.menu) {
                        _animateTo(0.8);
                      } else if (state.step == ReviewStep.form) {
                        _animateTo(0.65);
                      } else if (state.step == ReviewStep.success) {
                        _animateTo(0.5);
                      }

                      if (state.submissionStatus ==
                          ReviewSubmissionStatus.success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Review enviada correctamente.'),
                            backgroundColor: AppColor.greenNormal,
                          ),
                        );
                      }

                      if (state.submissionStatus ==
                          ReviewSubmissionStatus.failure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              state.errorMessage ??
                                  'No se pudo enviar la review.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      Widget content;

                      switch (state.step) {
                        case ReviewStep.menu:
                          content = ComplianceMenuView(
                            scrollController: scrollController,
                            placeId: widget.placeId,
                          );
                        case ReviewStep.form:
                          content = AccessibilityFormView(
                            scrollController: scrollController,
                          );
                        case ReviewStep.success:
                          content = ReviewSuccessView(
                            scrollController: scrollController,
                            onFinish: () {
                              Navigator.of(context).pop(true);
                            },
                          );
                      }

                      return Stack(
                        children: [
                          Positioned.fill(child: content),
                          if (state.isSubmitting)
                            const Positioned.fill(
                              child: ColoredBox(
                                color: Color(0x66000000),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColor.primaryNormal,
                                  ),
                                ),
                              ),
                            ),
                        ],
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
