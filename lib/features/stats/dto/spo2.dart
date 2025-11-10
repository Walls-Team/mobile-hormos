// class Spo2Record {
//   final DateTime date;
//   final double spo2;
//   final int dayIndex;

//   Spo2Record({
//     required this.date,
//     required this.spo2,
//     required this.dayIndex,
//   });

//   factory Spo2Record.fromJson(Map<String, dynamic> json) {
//     return Spo2Record(
//       date: DateTime.parse(json['date'] as String),
//       spo2: _parseDouble(json['spo2']),
//       dayIndex: json['day_index'] as int,
//     );
//   }

//   static double _parseDouble(dynamic value) {
//     if (value == null) return 0.0;
//     if (value is double) return value;
//     if (value is int) return value.toDouble();
//     if (value is String) return double.tryParse(value) ?? 0.0;
//     return 0.0;
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'date': date.toIso8601String(),
//       'spo2': spo2,
//       'day_index': dayIndex,
//     };
//   }

//   // Métodos de utilidad
//   String get spo2Category {
//     if (spo2 >= 95) return 'Normal';
//     if (spo2 >= 93) return 'Mild Hypoxemia';
//     if (spo2 >= 90) return 'Moderate Hypoxemia';
//     return 'Severe Hypoxemia';
//   }

//   String get spo2Description {
//     if (spo2 >= 95) return 'Normal oxygen saturation';
//     if (spo2 >= 93) return 'Mildly low oxygen levels';
//     if (spo2 >= 90) return 'Moderately low oxygen levels';
//     return 'Severely low oxygen levels - consult healthcare provider';
//   }

//   // Color get spo2Color {
//   //   if (spo2 >= 95) return const Color(0xFF4CAF50); // Green
//   //   if (spo2 >= 93) return const Color(0xFFFFC107); // Amber
//   //   if (spo2 >= 90) return const Color(0xFFFF9800); // Orange
//   //   return const Color(0xFFF44336); // Red
//   // }

//   bool get isNormal => spo2 >= 95;
//   bool get isMildHypoxemia => spo2 >= 93 && spo2 < 95;
//   bool get isModerateHypoxemia => spo2 >= 90 && spo2 < 93;
//   bool get isSevereHypoxemia => spo2 < 90;

//   // Calcular nivel de preocupación (0-100, donde 0 es sin preocupación)
//   double get concernLevel {
//     if (spo2 >= 95) return 0.0;
//     if (spo2 >= 93) return 25.0;
//     if (spo2 >= 90) return 50.0;
//     return 100.0;
//   }

//   // Verificar si requiere atención médica
//   bool get requiresMedicalAttention => spo2 < 90;

//   Spo2Record copyWith({
//     DateTime? date,
//     double? spo2,
//     int? dayIndex,
//   }) {
//     return Spo2Record(
//       date: date ?? this.date,
//       spo2: spo2 ?? this.spo2,
//       dayIndex: dayIndex ?? this.dayIndex,
//     );
//   }

//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is Spo2Record &&
//           runtimeType == other.runtimeType &&
//           date == other.date &&
//           spo2 == other.spo2 &&
//           dayIndex == other.dayIndex;

//   @override
//   int get hashCode => date.hashCode ^ spo2.hashCode ^ dayIndex.hashCode;

//   @override
//   String toString() {
//     return 'Spo2Record{date: $date, spo2: ${spo2.toStringAsFixed(1)}%, dayIndex: $dayIndex}';
//   }
// }