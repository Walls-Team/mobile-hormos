class RemSleepRecord {
  final double sleepDurationRem;
  final String date;

  RemSleepRecord({required this.sleepDurationRem, required this.date});

  factory RemSleepRecord.fromJson(Map<String, dynamic> json) {
    return RemSleepRecord(
      sleepDurationRem: (json['sleep_duration_rem'] as num).toDouble(),
      date: json['date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'sleep_duration_rem': sleepDurationRem, 'date': date};
  }

  @override
  String toString() {
    return 'RemSleepRecord{sleepDurationRem: $sleepDurationRem, date: $date}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RemSleepRecord &&
          runtimeType == other.runtimeType &&
          sleepDurationRem == other.sleepDurationRem &&
          date == other.date;

  @override
  int get hashCode => sleepDurationRem.hashCode ^ date.hashCode;

  RemSleepRecord copyWith({double? sleepDurationRem, String? date}) {
    return RemSleepRecord(
      sleepDurationRem: sleepDurationRem ?? this.sleepDurationRem,
      date: date ?? this.date,
    );
  }
}
