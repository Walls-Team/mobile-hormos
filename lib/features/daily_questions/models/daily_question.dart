class DailyQuestion {
  final String id;
  final String title;
  final String subtitle;
  bool? answer; // true = yes (check), false = no (X), null = not answered

  DailyQuestion({
    required this.id,
    required this.title,
    required this.subtitle,
    this.answer,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'answer': answer,
    };
  }
}
