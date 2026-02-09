// =============================================
// SLEEP EFFICIENCY DTOs
// =============================================

class SleepEfficiencyData {
  final List<SleepEfficiencyRecord> records;

  SleepEfficiencyData({required this.records});

  factory SleepEfficiencyData.empty() {
    return SleepEfficiencyData(records: []);
  }

  factory SleepEfficiencyData.fromJson(dynamic json) {
    if (json is List) {
      print('soy list');
      return SleepEfficiencyData(
        records: json.map((item) => SleepEfficiencyRecord.fromJson(item)).toList(),
      );
    } else {
      print('no es list');
      throw ArgumentError('Expected List but got ${json.runtimeType}');
    }
  }
}

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
      sleepEfficiency: (json['sleep_efficiency'] as num).toDouble(),
      dayIndex: json['day_index'] != null ? (json['day_index'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'sleep_efficiency': sleepEfficiency,
      'day_index': dayIndex,
    };
  }

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
  String toString() {
    return 'SleepEfficiencyRecord{date: $date, efficiency: $sleepEfficiency%, dayIndex: $dayIndex}';
  }
}

// =============================================
// SLEEP DURATION DTOs
// =============================================

class SleepDurationData {
  final List<SleepDurationRecord> records;

  SleepDurationData({required this.records});

  factory SleepDurationData.empty() {
    return SleepDurationData(records: []);
  }

  factory SleepDurationData.fromJson(dynamic json) {
    if (json is List) {
      return SleepDurationData(
        records: json.map((item) => SleepDurationRecord.fromJson(item)).toList(),
      );
    } else {
      throw ArgumentError('Expected List but got ${json.runtimeType}');
    }
  }
}

class SleepDurationRecord {
  final DateTime date;
  final double sleepDuration;
  final double sleepDurationDeep;
  final double sleepDurationRem;
  final int dayIndex;

  SleepDurationRecord({
    required this.date,
    required this.sleepDuration,
    required this.sleepDurationDeep,
    required this.sleepDurationRem,
    required this.dayIndex,
  });

  factory SleepDurationRecord.fromJson(Map<String, dynamic> json) {
    return SleepDurationRecord(
      date: DateTime.parse(json['date'] as String),
      sleepDuration: (json['sleep_duration'] as num).toDouble(),
      sleepDurationDeep: (json['sleep_duration_deep'] as num).toDouble(),
      sleepDurationRem: (json['sleep_duration_rem'] as num).toDouble(),
      dayIndex: json['day_index'] != null ? (json['day_index'] as num).toInt() : 0,
    );
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
  double get lightSleepDuration => sleepDuration - sleepDurationDeep - sleepDurationRem;
  
  double get deepSleepPercentage => sleepDuration > 0 ? (sleepDurationDeep / sleepDuration) * 100 : 0;
  
  double get remSleepPercentage => sleepDuration > 0 ? (sleepDurationRem / sleepDuration) * 100 : 0;

  SleepDurationRecord copyWith({
    DateTime? date,
    double? sleepDuration,
    double? sleepDurationDeep,
    double? sleepDurationRem,
    int? dayIndex,
  }) {
    return SleepDurationRecord(
      date: date ?? this.date,
      sleepDuration: sleepDuration ?? this.sleepDuration,
      sleepDurationDeep: sleepDurationDeep ?? this.sleepDurationDeep,
      sleepDurationRem: sleepDurationRem ?? this.sleepDurationRem,
      dayIndex: dayIndex ?? this.dayIndex,
    );
  }

  @override
  String toString() {
    return 'SleepDurationRecord{date: $date, duration: $sleepDuration, deep: $sleepDurationDeep, rem: $sleepDurationRem, dayIndex: $dayIndex}';
  }
}

// =============================================
// HEART RATE DTOs
// =============================================

class HeartRateData {
  final List<HeartRateRecord> records;

  HeartRateData({required this.records});

  factory HeartRateData.empty() {
    return HeartRateData(records: []);
  }

  factory HeartRateData.fromJson(dynamic json) {
    if (json is List) {
      return HeartRateData(
        records: json.map((item) => HeartRateRecord.fromJson(item)).toList(),
      );
    } else {
      throw ArgumentError('Expected List but got ${json.runtimeType}');
    }
  }
}

class HeartRateRecord {
  final DateTime date;
  final double? heartRate;
  final double? heartRateResting;
  final double? heartRateMax;
  final double? hrvRmssd;
  final int dayIndex;

  HeartRateRecord({
    required this.date,
    required this.heartRate,
    required this.heartRateResting,
    required this.heartRateMax,
    required this.hrvRmssd,
    required this.dayIndex,
  });

  factory HeartRateRecord.fromJson(Map<String, dynamic> json) {
    return HeartRateRecord(
      date: DateTime.parse(json['date'] as String),
      heartRate: (json['heartrate'] as num?)?.toDouble(),
      heartRateResting: (json['heartrate_resting'] as num?)?.toDouble(),
      heartRateMax: (json['heartrate_max'] as num?)?.toDouble(),
      hrvRmssd: (json['hrv_rmssd'] as num?)?.toDouble(),
      dayIndex: json['day_index'] != null ? (json['day_index'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'heartrate': heartRate,
      'heartrate_resting': heartRateResting,
      'heartrate_max': heartRateMax,
      'hrv_rmssd': hrvRmssd,
      'day_index': dayIndex,
    };
  }

  // Métodos de utilidad
  bool get hasCompleteData =>
      heartRate != null && heartRateResting != null && heartRateMax != null && hrvRmssd != null;

  double? get heartRateReserve {
    if (heartRateMax == null || heartRateResting == null) return null;
    return heartRateMax! - heartRateResting!;
  }

  HeartRateRecord copyWith({
    DateTime? date,
    double? heartRate,
    double? heartRateResting,
    double? heartRateMax,
    double? hrvRmssd,
    int? dayIndex,
  }) {
    return HeartRateRecord(
      date: date ?? this.date,
      heartRate: heartRate ?? this.heartRate,
      heartRateResting: heartRateResting ?? this.heartRateResting,
      heartRateMax: heartRateMax ?? this.heartRateMax,
      hrvRmssd: hrvRmssd ?? this.hrvRmssd,
      dayIndex: dayIndex ?? this.dayIndex,
    );
  }

  @override
  String toString() {
    return 'HeartRateRecord{date: $date, hr: $heartRate, resting: $heartRateResting, max: $heartRateMax, hrv: $hrvRmssd, dayIndex: $dayIndex}';
  }
}

// =============================================
// SpO2 DTOs
// =============================================

class Spo2Data {
  final List<Spo2Record> records;

  Spo2Data({required this.records});

  factory Spo2Data.empty() {
    return Spo2Data(records: []);
  }

  factory Spo2Data.fromJson(dynamic json) {
    if (json is List) {
      return Spo2Data(
        records: json.map((item) => Spo2Record.fromJson(item)).toList(),
      );
    } else {
      throw ArgumentError('Expected List but got ${json.runtimeType}');
    }
  }
}

class Spo2Record {
  final DateTime date;
  final double spo2;
  final int dayIndex;

  Spo2Record({
    required this.date,
    required this.spo2,
    required this.dayIndex,
  });

  factory Spo2Record.fromJson(Map<String, dynamic> json) {
    return Spo2Record(
      date: DateTime.parse(json['date'] as String),
      spo2: (json['spo2'] as num).toDouble(),
      dayIndex: json['day_index'] != null ? (json['day_index'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'spo2': spo2,
      'day_index': dayIndex,
    };
  }

  // Métodos de utilidad
  String get spo2Category {
    if (spo2 >= 95) return 'Normal';
    if (spo2 >= 93) return 'Mild Hypoxemia';
    if (spo2 >= 90) return 'Moderate Hypoxemia';
    return 'Severe Hypoxemia';
  }

  bool get requiresMedicalAttention => spo2 < 90;

  Spo2Record copyWith({
    DateTime? date,
    double? spo2,
    int? dayIndex,
  }) {
    return Spo2Record(
      date: date ?? this.date,
      spo2: spo2 ?? this.spo2,
      dayIndex: dayIndex ?? this.dayIndex,
    );
  }

  @override
  String toString() {
    return 'Spo2Record{date: $date, spo2: ${spo2.toStringAsFixed(1)}%, dayIndex: $dayIndex}';
  }
}

// =============================================
// CALORIES DTOs
// =============================================

class CaloriesData {
  final List<CalorieRecord> records;

  CaloriesData({required this.records});

  factory CaloriesData.empty() {
    return CaloriesData(records: []);
  }

  factory CaloriesData.fromJson(dynamic json) {
    if (json is List) {
      return CaloriesData(
        records: json.map((item) => CalorieRecord.fromJson(item)).toList(),
      );
    } else {
      throw ArgumentError('Expected List but got ${json.runtimeType}');
    }
  }
}

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
      date: DateTime.parse(json['date'] as String),
      caloriesBurned: (json['calories_burned'] as num?)?.toDouble(),
      dayIndex: json['day_index'] != null ? (json['day_index'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'calories_burned': caloriesBurned,
      'day_index': dayIndex,
    };
  }

  // Métodos de utilidad
  bool get hasCaloriesData => caloriesBurned != null;
  
  double get caloriesBurnedOrZero => caloriesBurned ?? 0.0;

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
    return 'CalorieRecord{date: $date, calories: $caloriesBurned, dayIndex: $dayIndex}';
  }
}

// =============================================
// SLEEP INTERRUPTIONS DTOs
// =============================================

class SleepInterruptionsData {
  final List<SleepInterruptionRecord> records;

  SleepInterruptionsData({required this.records});

  factory SleepInterruptionsData.empty() {
    return SleepInterruptionsData(records: []);
  }

  factory SleepInterruptionsData.fromJson(dynamic json) {
    if (json is List) {
      return SleepInterruptionsData(
        records: json.map((item) => SleepInterruptionRecord.fromJson(item)).toList(),
      );
    } else {
      throw ArgumentError('Expected List but got ${json.runtimeType}');
    }
  }
}

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
      sleepInterruptions: json['sleep_interruptions'] != null ? (json['sleep_interruptions'] as num).toInt() : 0,
      dayIndex: json['day_index'] != null ? (json['day_index'] as num).toInt() : 0,
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

  bool get isExcellent => sleepInterruptions <= 2;
  bool get isGood => sleepInterruptions > 2 && sleepInterruptions <= 4;
  bool get isModerate => sleepInterruptions > 4 && sleepInterruptions <= 7;
  bool get isHigh => sleepInterruptions > 7 && sleepInterruptions <= 10;
  bool get isVeryHigh => sleepInterruptions > 10;

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
  String toString() {
    return 'SleepInterruptionRecord{date: $date, interruptions: $sleepInterruptions, dayIndex: $dayIndex}';
  }
}

// =============================================
// ALL STATS WRAPPER
// =============================================

class AllStats {
  final SleepEfficiencyData sleepEfficiency;
  final SleepDurationData sleepDuration;
  final HeartRateData heartRate;
  final Spo2Data spo2;
  final CaloriesData calories;
  final SleepInterruptionsData sleepInterruptions;

  bool get isSynchronizing =>
      sleepEfficiency.records.isEmpty &&
      sleepDuration.records.isEmpty &&
      heartRate.records.isEmpty &&
      spo2.records.isEmpty &&
      calories.records.isEmpty &&
      sleepInterruptions.records.isEmpty;

  factory AllStats.empty() {
    return AllStats(
      sleepEfficiency: SleepEfficiencyData.empty(),
      sleepDuration: SleepDurationData.empty(),
      heartRate: HeartRateData.empty(),
      spo2: Spo2Data.empty(),
      calories: CaloriesData.empty(),
      sleepInterruptions: SleepInterruptionsData.empty(),
    );
  }

  AllStats({
    required this.sleepEfficiency,
    required this.sleepDuration,
    required this.heartRate,
    required this.spo2,
    required this.calories,
    required this.sleepInterruptions,
  });

  Map<String, dynamic> toJson() {
    return {
      'sleepEfficiency': sleepEfficiency.records.map((e) => e.toJson()).toList(),
      'sleepDuration': sleepDuration.records.map((e) => e.toJson()).toList(),
      'heartRate': heartRate.records.map((e) => e.toJson()).toList(),
      'spo2': spo2.records.map((e) => e.toJson()).toList(),
      'calories': calories.records.map((e) => e.toJson()).toList(),
      'sleepInterruptions': sleepInterruptions.records.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'AllStats{\n'
        '  sleepEfficiency: ${sleepEfficiency.records.length} records,\n'
        '  sleepDuration: ${sleepDuration.records.length} records,\n'
        '  heartRate: ${heartRate.records.length} records,\n'
        '  spo2: ${spo2.records.length} records,\n'
        '  calories: ${calories.records.length} records,\n'
        '  sleepInterruptions: ${sleepInterruptions.records.length} records\n'
        '}';
  }
}

// =============================================
// API RESPONSE WRAPPER (para respuestas del backend)
// =============================================

class ApiResponse<T> {
  final String message;
  final String error;
  final T data;

  ApiResponse({
    required this.message,
    required this.error,
    required this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJson) {
    return ApiResponse(
      message: json['message'] as String? ?? '',
      error: json['error'] as String? ?? '',
      data: fromJson(json['data']),
    );
  }

  bool get isSuccess => error.isEmpty;

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'error': error,
      'data': data,
    };
  }
}