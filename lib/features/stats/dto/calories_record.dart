class CalorieRecord {
  final DateTime date;
  final double? caloriesBurned;
  final int dayIndex;

  CalorieRecord({
    required this.date,
    required this.caloriesBurned,
    required this.dayIndex,
  });

  factory CalorieRecord.fromJson(Map<String, dynamic> json) {
    return CalorieRecord(
      date: DateTime.parse(json['date']),
      caloriesBurned: json['calories_burned']?.toDouble(),
      dayIndex: json['day_index'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'calories_burned': caloriesBurned,
      'day_index': dayIndex,
    };
  }

  CalorieRecord copyWith({
    DateTime? date,
    double? caloriesBurned,
    int? dayIndex,
  }) {
    return CalorieRecord(
      date: date ?? this.date,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      dayIndex: dayIndex ?? this.dayIndex,
    );
  }

  @override
  String toString() {
    return 'CalorieRecord{date: $date, caloriesBurned: $caloriesBurned, dayIndex: $dayIndex}';
  }
}