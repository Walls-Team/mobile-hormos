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
      heartRate: _parseNullableDouble(json['heartrate']),
      heartRateResting: _parseNullableDouble(json['heartrate_resting']),
      heartRateMax: _parseNullableDouble(json['heartrate_max']),
      hrvRmssd: _parseNullableDouble(json['hrv_rmssd']),
      dayIndex: json['day_index'] as int,
    );
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
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

  bool get hasHeartRateData => heartRate != null;
  bool get hasRestingHeartRateData => heartRateResting != null;
  bool get hasMaxHeartRateData => heartRateMax != null;
  bool get hasHrvData => hrvRmssd != null;

  // Categorías de ritmo cardíaco en reposo
  String get restingHeartRateCategory {
    final resting = heartRateResting;
    if (resting == null) return 'Unknown';
    if (resting < 60) return 'Athlete';
    if (resting < 70) return 'Excellent';
    if (resting < 80) return 'Good';
    if (resting < 90) return 'Average';
    return 'High';
  }

  // Categorías de HRV
  String get hrvCategory {
    final hrv = hrvRmssd;
    if (hrv == null) return 'Unknown';
    if (hrv >= 60) return 'Excellent';
    if (hrv >= 40) return 'Good';
    if (hrv >= 20) return 'Fair';
    return 'Poor';
  }

  // Calcular reserva de ritmo cardíaco
  double? get heartRateReserve {
    if (heartRateMax == null || heartRateResting == null) return null;
    return heartRateMax! - heartRateResting!;
  }

  // Calcular porcentaje de reserva de ritmo cardíaco
  double? get heartRateReservePercentage {
    if (heartRate == null || heartRateMax == null || heartRateResting == null) return null;
    if (heartRateMax == heartRateResting) return null;
    return ((heartRate! - heartRateResting!) / (heartRateMax! - heartRateResting!)) * 100;
  }

  // Intensidad del ejercicio basado en porcentaje de reserva
  String? get exerciseIntensity {
    final percentage = heartRateReservePercentage;
    if (percentage == null) return null;
    if (percentage < 50) return 'Very Light';
    if (percentage < 60) return 'Light';
    if (percentage < 70) return 'Moderate';
    if (percentage < 80) return 'Hard';
    if (percentage < 90) return 'Very Hard';
    return 'Maximum';
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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeartRateRecord &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          heartRate == other.heartRate &&
          heartRateResting == other.heartRateResting &&
          heartRateMax == other.heartRateMax &&
          hrvRmssd == other.hrvRmssd &&
          dayIndex == other.dayIndex;

  @override
  int get hashCode =>
      date.hashCode ^
      heartRate.hashCode ^
      heartRateResting.hashCode ^
      heartRateMax.hashCode ^
      hrvRmssd.hashCode ^
      dayIndex.hashCode;

  @override
  String toString() {
    return 'HeartRateRecord{date: $date, hr: $heartRate, resting: $heartRateResting, max: $heartRateMax, hrv: $hrvRmssd, dayIndex: $dayIndex}';
  }
}