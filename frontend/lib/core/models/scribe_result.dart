class ScribePolishResult {
  final String vintage;
  final String poetic;
  final String midnightDiary;
  final String minimalist;

  const ScribePolishResult({
    required this.vintage,
    required this.poetic,
    required this.midnightDiary,
    required this.minimalist,
  });

  factory ScribePolishResult.fromJson(Map<String, dynamic> json) {
    return ScribePolishResult(
      vintage: json['vintage'] as String? ?? '',
      poetic: json['poetic'] as String? ?? '',
      midnightDiary: json['midnightDiary'] as String? ?? '',
      minimalist: json['minimalist'] as String? ?? '',
    );
  }
}
