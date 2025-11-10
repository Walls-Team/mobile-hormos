class EnergyStats {
  final double currentLevel;
  final double highestLevel;
  final double lowestLevel;
  final double averageLevel;

  EnergyStats({
    required this.currentLevel,
    required this.highestLevel,
    required this.lowestLevel,
    required this.averageLevel,
  });

  factory EnergyStats.fromJson(Map<String, dynamic> json) {
    return EnergyStats(
      currentLevel: (json['current_level'] as num).toDouble(),
      highestLevel: (json['highest_level'] as num).toDouble(),
      lowestLevel: (json['lowest_level'] as num).toDouble(),
      averageLevel: (json['average_level'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_level': currentLevel,
      'highest_level': highestLevel,
      'lowest_level': lowestLevel,
      'average_level': averageLevel,
    };
  }

  @override
  String toString() {
    return 'EnergyStats{currentLevel: $currentLevel, highestLevel: $highestLevel, lowestLevel: $lowestLevel, averageLevel: $averageLevel}';
  }
}