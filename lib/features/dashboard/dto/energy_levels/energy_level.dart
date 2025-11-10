class EnergyLevel {
  final double energy;
  final String date;

  EnergyLevel({
    required this.energy,
    required this.date,
  });

  factory EnergyLevel.fromJson(Map<String, dynamic> json) {
    return EnergyLevel(
      energy: (json['energy'] as num).toDouble(),
      date: json['date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'energy': energy,
      'date': date,
    };
  }

  @override
  String toString() {
    return 'EnergyLevel{energy: $energy, date: $date}';
  }
}