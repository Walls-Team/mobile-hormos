class SleepEfficiencyRecord {
  final DateTime date;
  final double sleepEfficiency;
  final int dayIndex;

  SleepEfficiencyRecord({
    required this.date,
    required this.sleepEfficiency,
    required this.dayIndex,
  });

  factory SleepEfficiencyRecord.fromJson(Map<String, dynamic> json) {
    return SleepEfficiencyRecord(
      date: DateTime.parse(json['date'] as String),
      sleepEfficiency: _parseDouble(json['sleep_efficiency']),
      dayIndex: json['day_index'] as int,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'sleep_efficiency': sleepEfficiency,
      'day_index': dayIndex,
    };
  }

  // Métodos de utilidad
  String get efficiencyCategory {
    if (sleepEfficiency >= 90) return 'Excellent';
    if (sleepEfficiency >= 80) return 'Good';
    if (sleepEfficiency >= 70) return 'Fair';
    return 'Poor';
  }

  String get efficiencyDescription {
    if (sleepEfficiency >= 90) return 'Highly efficient sleep';
    if (sleepEfficiency >= 80) return 'Good sleep efficiency';
    if (sleepEfficiency >= 70) return 'Moderate sleep efficiency';
    return 'Low sleep efficiency';
  }

  // Color get efficiencyColor {
  //   if (sleepEfficiency >= 90) return const Color(0xFF4CAF50); // Green
  //   if (sleepEfficiency >= 80) return const Color(0xFF8BC34A); // Light Green
  //   if (sleepEfficiency >= 70) return const Color(0xFFFFC107); // Amber
  //   return const Color(0xFFF44336); // Red
  // }

  bool get isExcellent => sleepEfficiency >= 90;
  bool get isGood => sleepEfficiency >= 80 && sleepEfficiency < 90;
  bool get isFair => sleepEfficiency >= 70 && sleepEfficiency < 80;
  bool get isPoor => sleepEfficiency < 70;

  SleepEfficiencyRecord copyWith({
    DateTime? date,
    double? sleepEfficiency,
    int? dayIndex,
  }) {
    return SleepEfficiencyRecord(
      date: date ?? this.date,
      sleepEfficiency: sleepEfficiency ?? this.sleepEfficiency,
      dayIndex: dayIndex ?? this.dayIndex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepEfficiencyRecord &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          sleepEfficiency == other.sleepEfficiency &&
          dayIndex == other.dayIndex;

  @override
  int get hashCode =>
      date.hashCode ^ sleepEfficiency.hashCode ^ dayIndex.hashCode;

  @override
  String toString() {
    return 'SleepEfficiencyRecord{date: $date, efficiency: $sleepEfficiency%, dayIndex: $dayIndex}';
  }
}