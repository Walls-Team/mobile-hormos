class SleepRecord {
  final DateTime date;
  final double sleepDuration;
  final double sleepDurationDeep;
  final double sleepDurationRem;
  final int dayIndex;

  SleepRecord({
    required this.date,
    required this.sleepDuration,
    required this.sleepDurationDeep,
    required this.sleepDurationRem,
    required this.dayIndex,
  });

  factory SleepRecord.fromJson(Map<String, dynamic> json) {
    return SleepRecord(
      date: DateTime.parse(json['date'] as String),
      sleepDuration: _parseDouble(json['sleep_duration']),
      sleepDurationDeep: _parseDouble(json['sleep_duration_deep']),
      sleepDurationRem: _parseDouble(json['sleep_duration_rem']),
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
      'sleep_duration': sleepDuration,
      'sleep_duration_deep': sleepDurationDeep,
      'sleep_duration_rem': sleepDurationRem,
      'day_index': dayIndex,
    };
  }

  // Métodos de utilidad
  double get totalSleepDuration => sleepDuration;
  
  double get lightSleepDuration {
    return sleepDuration - sleepDurationDeep - sleepDurationRem;
  }

  double get deepSleepPercentage {
    return sleepDuration > 0 ? (sleepDurationDeep / sleepDuration) * 100 : 0;
  }

  double get remSleepPercentage {
    return sleepDuration > 0 ? (sleepDurationRem / sleepDuration) * 100 : 0;
  }

  double get lightSleepPercentage {
    return sleepDuration > 0 ? (lightSleepDuration / sleepDuration) * 100 : 0;
  }

  String get sleepQuality {
    if (sleepDuration >= 7) return 'Excellent';
    if (sleepDuration >= 6) return 'Good';
    if (sleepDuration >= 5) return 'Fair';
    return 'Poor';
  }

  SleepRecord copyWith({
    DateTime? date,
    double? sleepDuration,
    double? sleepDurationDeep,
    double? sleepDurationRem,
    int? dayIndex,
  }) {
    return SleepRecord(
      date: date ?? this.date,
      sleepDuration: sleepDuration ?? this.sleepDuration,
      sleepDurationDeep: sleepDurationDeep ?? this.sleepDurationDeep,
      sleepDurationRem: sleepDurationRem ?? this.sleepDurationRem,
      dayIndex: dayIndex ?? this.dayIndex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepRecord &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          sleepDuration == other.sleepDuration &&
          sleepDurationDeep == other.sleepDurationDeep &&
          sleepDurationRem == other.sleepDurationRem &&
          dayIndex == other.dayIndex;

  @override
  int get hashCode =>
      date.hashCode ^
      sleepDuration.hashCode ^
      sleepDurationDeep.hashCode ^
      sleepDurationRem.hashCode ^
      dayIndex.hashCode;

  @override
  String toString() {
    return 'SleepRecord{date: $date, duration: $sleepDuration, deep: $sleepDurationDeep, rem: $sleepDurationRem, dayIndex: $dayIndex}';
  }
}