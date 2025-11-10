class SleepRecord {
  final int hrvRmssd;
  final int sleepEfficiency;
  final double sleepDuration;
  final int sleepInterruptions;
  final double sleepScore;
  final String date;

  SleepRecord({
    required this.hrvRmssd,
    required this.sleepEfficiency,
    required this.sleepDuration,
    required this.sleepInterruptions,
    required this.sleepScore,
    required this.date,
  });

  factory SleepRecord.fromJson(Map<String, dynamic> json) {
    return SleepRecord(
      hrvRmssd: json['hrv_rmssd'] as int,
      sleepEfficiency: json['sleep_efficiency'] as int,
      sleepDuration: (json['sleep_duration'] as num).toDouble(),
      sleepInterruptions: json['sleep_interruptions'] as int,
      sleepScore: (json['sleep_score'] as num).toDouble(),
      date: json['date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hrv_rmssd': hrvRmssd,
      'sleep_efficiency': sleepEfficiency,
      'sleep_duration': sleepDuration,
      'sleep_interruptions': sleepInterruptions,
      'sleep_score': sleepScore,
      'date': date,
    };
  }

  @override
  String toString() {
    return 'SleepRecord{hrvRmssd: $hrvRmssd, sleepEfficiency: $sleepEfficiency, sleepDuration: $sleepDuration, sleepInterruptions: $sleepInterruptions, sleepScore: $sleepScore, date: $date}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepRecord &&
          runtimeType == other.runtimeType &&
          hrvRmssd == other.hrvRmssd &&
          sleepEfficiency == other.sleepEfficiency &&
          sleepDuration == other.sleepDuration &&
          sleepInterruptions == other.sleepInterruptions &&
          sleepScore == other.sleepScore &&
          date == other.date;

  @override
  int get hashCode =>
      hrvRmssd.hashCode ^
      sleepEfficiency.hashCode ^
      sleepDuration.hashCode ^
      sleepInterruptions.hashCode ^
      sleepScore.hashCode ^
      date.hashCode;

  SleepRecord copyWith({
    int? hrvRmssd,
    int? sleepEfficiency,
    double? sleepDuration,
    int? sleepInterruptions,
    double? sleepScore,
    String? date,
  }) {
    return SleepRecord(
      hrvRmssd: hrvRmssd ?? this.hrvRmssd,
      sleepEfficiency: sleepEfficiency ?? this.sleepEfficiency,
      sleepDuration: sleepDuration ?? this.sleepDuration,
      sleepInterruptions: sleepInterruptions ?? this.sleepInterruptions,
      sleepScore: sleepScore ?? this.sleepScore,
      date: date ?? this.date,
    );
  }
}