import 'package:genius_hormo/features/dashboard/dto/basic_metrics/sleep_data_dto.dart';
import 'package:genius_hormo/features/dashboard/dto/energy_levels/energy_data.dart';

class HealthData {
  final EnergyData energy;
  final SleepData sleep;

  const HealthData({
    required this.energy,
    required this.sleep,
  });

  bool get isSynchronizing {
    return sleep.dates.isEmpty && sleep.sleepResume.isEmpty;
  }

  factory HealthData.empty() {
    return HealthData(
      energy: EnergyData.empty(),
      sleep: SleepData.empty(),
    );
  }
}