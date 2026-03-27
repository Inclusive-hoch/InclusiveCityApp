class ReviewStatDataRequestModel {
  final String rateChoice;
  final List<String> forms;

  const ReviewStatDataRequestModel({
    required this.rateChoice,
    required this.forms,
  });

  Map<String, dynamic> toJson() {
    return {
      'rateChoice': rateChoice,
      'forms': forms,
    };
  }
}
