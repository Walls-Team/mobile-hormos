class SleepInterruptionRecord {
  final DateTime date;
  final int sleepInterruptions;
  final int dayIndex;

  SleepInterruptionRecord({
    required this.date,
    required this.sleepInterruptions,
    required this.dayIndex,
  });

  factory SleepInterruptionRecord.fromJson(Map<String, dynamic> json) {
    return SleepInterruptionRecord(
      date: DateTime.parse(json['date'] as String),
      sleepInterruptions: json['sleep_interruptions'] as int,
      dayIndex: json['day_index'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'sleep_interruptions': sleepInterruptions,
      'day_index': dayIndex,
    };
  }

  // Métodos de utilidad
  String get interruptionLevel {
    if (sleepInterruptions <= 2) return 'Very Low';
    if (sleepInterruptions <= 4) return 'Low';
    if (sleepInterruptions <= 7) return 'Moderate';
    if (sleepInterruptions <= 10) return 'High';
    return 'Very High';
  }

  String get interruptionDescription {
    if (sleepInterruptions <= 2) return 'Excellent sleep continuity';
    if (sleepInterruptions <= 4) return 'Good sleep continuity';
    if (sleepInterruptions <= 7) return 'Moderate interruptions';
    if (sleepInterruptions <= 10) return 'Frequent interruptions';
    return 'Very fragmented sleep';
  }

  // Color get interruptionColor {
  //   if (sleepInterruptions <= 2) return const Color(0xFF4CAF50); // Green
  //   if (sleepInterruptions <= 4) return const Color(0xFF8BC34A); // Light Green
  //   if (sleepInterruptions <= 7) return const Color(0xFFFFC107); // Amber
  //   if (sleepInterruptions <= 10) return const Color(0xFFFF9800); // Orange
  //   return const Color(0xFFF44336); // Red
  // }

  bool get isExcellent => sleepInterruptions <= 2;
  bool get isGood => sleepInterruptions > 2 && sleepInterruptions <= 4;
  bool get isModerate => sleepInterruptions > 4 && sleepInterruptions <= 7;
  bool get isHigh => sleepInterruptions > 7 && sleepInterruptions <= 10;
  bool get isVeryHigh => sleepInterruptions > 10;

  // Calcular impacto en la calidad del sueño (0-100)
  double get sleepContinuityScore {
    if (sleepInterruptions <= 2) return 100.0;
    if (sleepInterruptions <= 10) {
      return 100.0 - ((sleepInterruptions - 2) * 10.0);
    }
    return 0.0;
  }

  SleepInterruptionRecord copyWith({
    DateTime? date,
    int? sleepInterruptions,
    int? dayIndex,
  }) {
    return SleepInterruptionRecord(
      date: date ?? this.date,
      sleepInterruptions: sleepInterruptions ?? this.sleepInterruptions,
      dayIndex: dayIndex ?? this.dayIndex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepInterruptionRecord &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          sleepInterruptions == other.sleepInterruptions &&
          dayIndex == other.dayIndex;

  @override
  int get hashCode =>
      date.hashCode ^ sleepInterruptions.hashCode ^ dayIndex.hashCode;

  @override
  String toString() {
    return 'SleepInterruptionRecord{date: $date, interruptions: $sleepInterruptions, dayIndex: $dayIndex}';
  }
}