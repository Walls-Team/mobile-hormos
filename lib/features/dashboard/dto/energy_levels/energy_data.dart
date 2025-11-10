import 'energy_stats.dart';
import 'energy_level.dart';

class EnergyData {
  final EnergyStats stats;
  final List<EnergyLevel> history;

  EnergyData({
    required this.stats,
    required this.history,
  });

  factory EnergyData.fromJson(Map<String, dynamic> json) {
    return EnergyData(
      stats: EnergyStats.fromJson(json['stats'] as Map<String, dynamic>),
      history: (json['history'] as List)
          .map((item) => EnergyLevel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stats': stats.toJson(),
      'history': history.map((item) => item.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'EnergyData{stats: $stats, history: $history}';
  }
}