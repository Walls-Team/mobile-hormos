class SleepSummary {
  final int hrvRmssd;
  final int sleepEfficiency;
  final double sleepDuration;
  final String date;

  SleepSummary({
    required this.hrvRmssd,
    required this.sleepEfficiency,
    required this.sleepDuration,
    required this.date,
  });

  factory SleepSummary.fromJson(Map<String, dynamic> json) {
    return SleepSummary(
      hrvRmssd: json['hrv_rmssd'] as int,
      sleepEfficiency: json['sleep_efficiency'] as int,
      sleepDuration: (json['sleep_duration'] as num).toDouble(),
      date: json['date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hrv_rmssd': hrvRmssd,
      'sleep_efficiency': sleepEfficiency,
      'sleep_duration': sleepDuration,
      'date': date,
    };
  }

  @override
  String toString() {
    return 'SleepSummary{hrvRmssd: $hrvRmssd, sleepEfficiency: $sleepEfficiency, sleepDuration: $sleepDuration, date: $date}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepSummary &&
          runtimeType == other.runtimeType &&
          hrvRmssd == other.hrvRmssd &&
          sleepEfficiency == other.sleepEfficiency &&
          sleepDuration == other.sleepDuration &&
          date == other.date;

  @override
  int get hashCode =>
      hrvRmssd.hashCode ^
      sleepEfficiency.hashCode ^
      sleepDuration.hashCode ^
      date.hashCode;

  SleepSummary copyWith({
    int? hrvRmssd,
    int? sleepEfficiency,
    double? sleepDuration,
    String? date,
  }) {
    return SleepSummary(
      hrvRmssd: hrvRmssd ?? this.hrvRmssd,
      sleepEfficiency: sleepEfficiency ?? this.sleepEfficiency,
      sleepDuration: sleepDuration ?? this.sleepDuration,
      date: date ?? this.date,
    );
  }
}