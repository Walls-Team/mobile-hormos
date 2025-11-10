class SpO2Record {
  final double spo2;
  final String date;

  SpO2Record({
    required this.spo2,
    required this.date,
  });

  factory SpO2Record.fromJson(Map<String, dynamic> json) {
    return SpO2Record(
      spo2: (json['spo2'] as num).toDouble(),
      date: json['date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'spo2': spo2,
      'date': date,
    };
  }

  @override
  String toString() {
    return 'SpO2Record{spo2: $spo2, date: $date}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpO2Record &&
          runtimeType == other.runtimeType &&
          spo2 == other.spo2 &&
          date == other.date;

  @override
  int get hashCode => spo2.hashCode ^ date.hashCode;

  SpO2Record copyWith({
    double? spo2,
    String? date,
  }) {
    return SpO2Record(
      spo2: spo2 ?? this.spo2,
      date: date ?? this.date,
    );
  }
}