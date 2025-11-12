import 'package:genius_hormo/features/dashboard/dto/basic_metrics/rem_sleep_record_dto.dart';
import 'package:genius_hormo/features/dashboard/dto/basic_metrics/sleep_record_dto.dart';
import 'package:genius_hormo/features/dashboard/dto/basic_metrics/sleep_summary_dto.dart';
import 'package:genius_hormo/features/dashboard/dto/basic_metrics/spo2_record_dto.dart';

class SleepData {
  final SleepSummary resume;
  final List<SleepRecord> sleepResume;
  final List<RemSleepRecord> remResume;
  final List<SpO2Record> spoResume;
  final List<String> dates;

  SleepData({
    required this.resume,
    required this.sleepResume,
    required this.remResume,
    required this.spoResume,
    required this.dates,
  });

  factory SleepData.fromJson(Map<String, dynamic> json) {
    return SleepData(
      resume: SleepSummary.fromJson(json['resume'] as Map<String, dynamic>),
      sleepResume: (json['sleep_resume'] as List<dynamic>?)
              ?.map((item) => SleepRecord.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      remResume: (json['rem_resume'] as List<dynamic>?)
              ?.map((item) => RemSleepRecord.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      spoResume: (json['spo_resume'] as List<dynamic>?)
              ?.map((item) => SpO2Record.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      dates: (json['dates'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resume': resume?.toJson(),
      'sleep_resume': sleepResume?.map((item) => item.toJson()).toList(),
      'rem_resume': remResume?.map((item) => item.toJson()).toList(),
      'spo_resume': spoResume?.map((item) => item.toJson()).toList(),
      'rem_resume': remResume.map((item) => item.toJson()).toList(),
      'spo_resume': spoResume.map((item) => item.toJson()).toList(),
      'dates': dates,
    };
  }

  @override
  String toString() {
    return 'SleepData{resume: $resume, sleepResume: $sleepResume, remResume: $remResume, spoResume: $spoResume, dates: $dates}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepData &&
          runtimeType == other.runtimeType &&
          resume == other.resume &&
          _listEquals(sleepResume, other.sleepResume) &&
          _listEquals(remResume, other.remResume) &&
          _listEquals(spoResume, other.spoResume) &&
          _listEquals(dates, other.dates);

  @override
  int get hashCode =>
      resume.hashCode ^
      sleepResume.hashCode ^
      remResume.hashCode ^
      spoResume.hashCode ^
      dates.hashCode;

  SleepData copyWith({
    SleepSummary? resume,
    List<SleepRecord>? sleepResume,
    List<RemSleepRecord>? remResume,
    List<SpO2Record>? spoResume,
    List<String>? dates,
  }) {
    return SleepData(
      resume: resume ?? this.resume,
      sleepResume: sleepResume ?? this.sleepResume,
      remResume: remResume ?? this.remResume,
      spoResume: spoResume ?? this.spoResume,
      dates: dates ?? this.dates,
    );
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}