// import 'package:genius_hormo/features/dashboard/dto/basic_metrics/sleep_record_dto.dart';
// import 'package:genius_hormo/features/stats/dto/calories_record.dart';
// import 'package:genius_hormo/features/stats/dto/heartrate.dart';
// import 'package:genius_hormo/features/stats/dto/sleep_efficiency.dart';
// import 'package:genius_hormo/features/stats/dto/sleep_interruptions.dart';
// import 'package:genius_hormo/features/stats/dto/spo2.dart';

// class CaloriesData {
//   final List<CalorieRecord> records;

//   CaloriesData({required this.records});

//   factory CaloriesData.fromJson(List<dynamic> json) {
//     return CaloriesData(
//       records: json.map((item) => CalorieRecord.fromJson(item)).toList(),
//     );
//   }

//   List<Map<String, dynamic>> toJson() {
//     return records.map((record) => record.toJson()).toList();
//   }
// }

// class SleepData {
//   final List<SleepRecord> records;

//   SleepData({required this.records});

//   factory SleepData.fromJson(List<dynamic> json) {
//     return SleepData(
//       records: json.map((item) => SleepRecord.fromJson(item)).toList(),
//     );
//   }

//   List<Map<String, dynamic>> toJson() {
//     return records.map((record) => record.toJson()).toList();
//   }
// }

// class SleepInterruptionsData {
//   final List<SleepInterruptionRecord> records;

//   SleepInterruptionsData({required this.records});

//   factory SleepInterruptionsData.fromJson(List<dynamic> json) {
//     return SleepInterruptionsData(
//       records: json.map((item) => SleepInterruptionRecord.fromJson(item)).toList(),
//     );
//   }

//   List<Map<String, dynamic>> toJson() {
//     return records.map((record) => record.toJson()).toList();
//   }
// }

// class Spo2Data {
//   final List<Spo2Record> records;

//   Spo2Data({required this.records});

//   factory Spo2Data.fromJson(List<dynamic> json) {
//     return Spo2Data(
//       records: json.map((item) => Spo2Record.fromJson(item)).toList(),
//     );
//   }

//   List<Map<String, dynamic>> toJson() {
//     return records.map((record) => record.toJson()).toList();
//   }
// }

// class SleepEfficiencyData {
//   final List<SleepEfficiencyRecord> records;

//   SleepEfficiencyData({required this.records});

//   factory SleepEfficiencyData.fromJson(List<dynamic> json) {
//     return SleepEfficiencyData(
//       records: json.map((item) => SleepEfficiencyRecord.fromJson(item)).toList(),
//     );
//   }

//   List<Map<String, dynamic>> toJson() {
//     return records.map((record) => record.toJson()).toList();
//   }
// }
// class HeartRateData {
//   final List<HeartRateRecord> records;

//   HeartRateData({required this.records});

//   factory HeartRateData.fromJson(List<dynamic> json) {
//     return HeartRateData(
//       records: json.map((item) => HeartRateRecord.fromJson(item)).toList(),
//     );
//   }

//   List<Map<String, dynamic>> toJson() {
//     return records.map((record) => record.toJson()).toList();
//   }
// }

