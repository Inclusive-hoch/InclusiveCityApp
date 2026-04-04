class ReviewStatDataRequestModel {
  final List<String> forms;

  const ReviewStatDataRequestModel({
    required this.forms,
  });

  Map<String, dynamic> toJson() {
    return {
      'forms': forms,
    };
  }
}
