import 'package:flutter/material.dart';
import 'package:genius_hormo/theme/colors_pallete.dart';
import 'package:genius_hormo/theme/theme.dart';
import 'package:genius_hormo/views/dashboard/components/rem_chart.dart';
import 'package:genius_hormo/views/dashboard/components/sleep_interruptions_chart.dart';
import 'package:genius_hormo/views/dashboard/components/spo_chart.dart';
import 'package:genius_hormo/views/dashboard/components/stats.dart';
import 'package:genius_hormo/views/dashboard/components/testosterone_chart.dart';
import 'package:glassmorphism/glassmorphism.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        // decoration: BoxDecoration(
        //  gradient: Theme.of(context).extension<AppGradientTheme>()?.backgroundGradient
        // ),

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 8,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TestosteroneChart(
                        energyData: [
                          ChartData('Jan', 75, Colors.blue),
                          ChartData('Feb', 85, Colors.green),
                          ChartData('Mar', 65, Colors.orange),
                          ChartData('Apr', 90, Colors.purple),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: StatCard(
                      duration: "92%",
                      title: "Sleep Efficiency",
                      icon: Icons.nightlight_round,
                    ),
                  ),

                  Expanded(
                    flex: 1,
                    child: StatCard(
                      duration: "7.9h",
                      title: "Sleep Duration",
                      icon: Icons.schedule,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: StatCard(
                      duration: "19",
                      title: "Hrv rmssd",
                      icon: Icons.monitor_heart,
                    ),
                  ),
                ],
              ),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SleepChart(
                        data: [
                          REMData(
                            sleepDurationRem: 1.04,
                            date: "2025-11-01T00:00:00",
                          ),
                          REMData(
                            sleepDurationRem: 0.83,
                            date: "2025-10-30T00:00:00",
                          ),
                          REMData(
                            sleepDurationRem: 1.23,
                            date: "2025-10-29T00:00:00",
                          ),
                          REMData(
                            sleepDurationRem: 0.88,
                            date: "2025-10-28T00:00:00",
                          ),
                          REMData(
                            sleepDurationRem: 0.78,
                            date: "2025-10-27T00:00:00",
                          ),
                          REMData(
                            sleepDurationRem: 1.08,
                            date: "2025-10-26T00:00:00",
                          ),
                          REMData(
                            sleepDurationRem: 1.38,
                            date: "2025-10-25T00:00:00",
                          ),
                          REMData(
                            sleepDurationRem: 1.14,
                            date: "2025-10-22T00:00:00",
                          ),
                          REMData(
                            sleepDurationRem: 1.18,
                            date: "2025-10-21T00:00:00",
                          ),
                          REMData(
                            sleepDurationRem: 1.67,
                            date: "2025-10-20T00:00:00",
                          ),
                          REMData(
                            sleepDurationRem: 2.04,
                            date: "2025-10-19T00:00:00",
                          ),
                          REMData(
                            sleepDurationRem: 1.24,
                            date: "2025-10-18T00:00:00",
                          ),
                          REMData(
                            sleepDurationRem: 0.56,
                            date: "2025-10-17T00:00:00",
                          ),
                          REMData(
                            sleepDurationRem: 0.94,
                            date: "2025-10-16T00:00:00",
                          ),
                          REMData(
                            sleepDurationRem: 0.67,
                            date: "2025-10-15T00:00:00",
                          ),
                          REMData(
                            sleepDurationRem: 1.57,
                            date: "2025-10-14T00:00:00",
                          ),
                          REMData(
                            sleepDurationRem: 0.8,
                            date: "2025-10-13T00:00:00",
                          ),
                          REMData(
                            sleepDurationRem: 0.83,
                            date: "2025-10-12T00:00:00",
                          ),
                          REMData(
                            sleepDurationRem: 0.43,
                            date: "2025-10-09T00:00:00",
                          ),
                          REMData(
                            sleepDurationRem: 1.26,
                            date: "2025-10-08T00:00:00",
                          ),
                          REMData(
                            sleepDurationRem: 0.65,
                            date: "2025-10-07T00:00:00",
                          ),
                          REMData(
                            sleepDurationRem: 1.13,
                            date: "2025-10-06T00:00:00",
                          ),
                          REMData(
                            sleepDurationRem: 0.26,
                            date: "2025-10-05T00:00:00",
                          ),
                          REMData(
                            sleepDurationRem: 0.88,
                            date: "2025-10-04T00:00:00",
                          ),
                          REMData(
                            sleepDurationRem: 1.17,
                            date: "2025-10-03T00:00:00",
                          ),
                          REMData(
                            sleepDurationRem: 1.01,
                            date: "2025-10-02T00:00:00",
                          ),
                          REMData(
                            sleepDurationRem: 2.09,
                            date: "2025-10-01T00:00:00",
                          ),
                          REMData(
                            sleepDurationRem: 0.63,
                            date: "2025-09-30T00:00:00",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SleepInterruptionsChart(
                        data: [
                          SleepData(
                            hrvRmssd: 25,
                            sleepEfficiency: 77,
                            sleepDuration: 5.96,
                            sleepInterruptions: 4,
                            sleepScore: 61.89,
                            date: DateTime(2025, 11, 1),
                          ),
                          SleepData(
                            hrvRmssd: 23,
                            sleepEfficiency: 71,
                            sleepDuration: 5.59,
                            sleepInterruptions: 6,
                            sleepScore: 46.31,
                            date: DateTime(2025, 10, 30),
                          ),
                          SleepData(
                            hrvRmssd: 23,
                            sleepEfficiency: 76,
                            sleepDuration: 5.68,
                            sleepInterruptions: 5,
                            sleepScore: 54.09,
                            date: DateTime(2025, 10, 29),
                          ),
                          SleepData(
                            hrvRmssd: 24,
                            sleepEfficiency: 91,
                            sleepDuration: 5.06,
                            sleepInterruptions: 9,
                            sleepScore: 34.77,
                            date: DateTime(2025, 10, 28),
                          ),
                          SleepData(
                            hrvRmssd: 22,
                            sleepEfficiency: 96,
                            sleepDuration: 5.22,
                            sleepInterruptions: 9,
                            sleepScore: 38.14,
                            date: DateTime(2025, 10, 27),
                          ),
                          SleepData(
                            hrvRmssd: 23,
                            sleepEfficiency: 96,
                            sleepDuration: 5.98,
                            sleepInterruptions: 6,
                            sleepScore: 59.66,
                            date: DateTime(2025, 10, 26),
                          ),
                          SleepData(
                            hrvRmssd: 19,
                            sleepEfficiency: 98,
                            sleepDuration: 6.37,
                            sleepInterruptions: 5,
                            sleepScore: 68.8,
                            date: DateTime(2025, 10, 25),
                          ),
                          SleepData(
                            hrvRmssd: 23,
                            sleepEfficiency: 81,
                            sleepDuration: 8.01,
                            sleepInterruptions: 10,
                            sleepScore: 42.4,
                            date: DateTime(2025, 10, 22),
                          ),
                          SleepData(
                            hrvRmssd: 22,
                            sleepEfficiency: 66,
                            sleepDuration: 6.73,
                            sleepInterruptions: 6,
                            sleepScore: 54.09,
                            date: DateTime(2025, 10, 21),
                          ),
                          SleepData(
                            hrvRmssd: 12,
                            sleepEfficiency: 84,
                            sleepDuration: 8.02,
                            sleepInterruptions: 13,
                            sleepScore: 28.6,
                            date: DateTime(2025, 10, 20),
                          ),
                          SleepData(
                            hrvRmssd: 40,
                            sleepEfficiency: 99,
                            sleepDuration: 7.03,
                            sleepInterruptions: 3,
                            sleepScore: 84.6,
                            date: DateTime(2025, 10, 19),
                          ),
                          SleepData(
                            hrvRmssd: 17,
                            sleepEfficiency: 93,
                            sleepDuration: 4.27,
                            sleepInterruptions: 1,
                            sleepScore: 68.8,
                            date: DateTime(2025, 10, 18),
                          ),
                          SleepData(
                            hrvRmssd: 21,
                            sleepEfficiency: 96,
                            sleepDuration: 3.15,
                            sleepInterruptions: 5,
                            sleepScore: 40.4,
                            date: DateTime(2025, 10, 17),
                          ),
                          SleepData(
                            hrvRmssd: 44,
                            sleepEfficiency: 80,
                            sleepDuration: 5.56,
                            sleepInterruptions: 5,
                            sleepScore: 54.66,
                            date: DateTime(2025, 10, 16),
                          ),
                          SleepData(
                            hrvRmssd: 32,
                            sleepEfficiency: 99,
                            sleepDuration: 3.91,
                            sleepInterruptions: 3,
                            sleepScore: 58.11,
                            date: DateTime(2025, 10, 15),
                          ),
                          SleepData(
                            hrvRmssd: 29,
                            sleepEfficiency: 83,
                            sleepDuration: 5.38,
                            sleepInterruptions: 3,
                            sleepScore: 64.31,
                            date: DateTime(2025, 10, 14),
                          ),
                          SleepData(
                            hrvRmssd: 37,
                            sleepEfficiency: 97,
                            sleepDuration: 3.95,
                            sleepInterruptions: 4,
                            sleepScore: 52.66,
                            date: DateTime(2025, 10, 13),
                          ),
                          SleepData(
                            hrvRmssd: 25,
                            sleepEfficiency: 95,
                            sleepDuration: 5.5,
                            sleepInterruptions: 8,
                            sleepScore: 45.14,
                            date: DateTime(2025, 10, 12),
                          ),
                          SleepData(
                            hrvRmssd: 24,
                            sleepEfficiency: 99,
                            sleepDuration: 1.3,
                            sleepInterruptions: 2,
                            sleepScore: 40.74,
                            date: DateTime(2025, 10, 9),
                          ),
                          SleepData(
                            hrvRmssd: 43,
                            sleepEfficiency: 99,
                            sleepDuration: 6.89,
                            sleepInterruptions: 8,
                            sleepScore: 58.66,
                            date: DateTime(2025, 10, 8),
                          ),
                          SleepData(
                            hrvRmssd: 20,
                            sleepEfficiency: 93,
                            sleepDuration: 2.78,
                            sleepInterruptions: 4,
                            sleepScore: 41.03,
                            date: DateTime(2025, 10, 7),
                          ),
                          SleepData(
                            hrvRmssd: 24,
                            sleepEfficiency: 97,
                            sleepDuration: 4.61,
                            sleepInterruptions: 7,
                            sleepScore: 43.31,
                            date: DateTime(2025, 10, 6),
                          ),
                          SleepData(
                            hrvRmssd: 17,
                            sleepEfficiency: 93,
                            sleepDuration: 2.46,
                            sleepInterruptions: 5,
                            sleepScore: 33.29,
                            date: DateTime(2025, 10, 5),
                          ),
                          SleepData(
                            hrvRmssd: 23,
                            sleepEfficiency: 87,
                            sleepDuration: 4,
                            sleepInterruptions: 4,
                            sleepScore: 49.09,
                            date: DateTime(2025, 10, 4),
                          ),
                          SleepData(
                            hrvRmssd: 25,
                            sleepEfficiency: 94,
                            sleepDuration: 5.82,
                            sleepInterruptions: 6,
                            sleepScore: 57.49,
                            date: DateTime(2025, 10, 3),
                          ),
                          SleepData(
                            hrvRmssd: 24,
                            sleepEfficiency: 75,
                            sleepDuration: 5.94,
                            sleepInterruptions: 11,
                            sleepScore: 25.91,
                            date: DateTime(2025, 10, 2),
                          ),
                          SleepData(
                            hrvRmssd: 26,
                            sleepEfficiency: 94,
                            sleepDuration: 7.54,
                            sleepInterruptions: 6,
                            sleepScore: 67.6,
                            date: DateTime(2025, 10, 1),
                          ),
                          SleepData(
                            hrvRmssd: 30,
                            sleepEfficiency: 100,
                            sleepDuration: 3.63,
                            sleepInterruptions: 1,
                            sleepScore: 66.11,
                            date: DateTime(2025, 9, 30),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SPOChart(
                        data: [
                          SPOData(spo2: 94.27, date: "2025-11-01T00:00:00"),
                          SPOData(spo2: 94.25, date: "2025-10-30T00:00:00"),
                          SPOData(spo2: 98.21, date: "2025-10-29T00:00:00"),
                          SPOData(spo2: 93.08, date: "2025-10-28T00:00:00"),
                          SPOData(spo2: 94.36, date: "2025-10-27T00:00:00"),
                          SPOData(spo2: 95.81, date: "2025-10-26T00:00:00"),
                          SPOData(spo2: 95.89, date: "2025-10-25T00:00:00"),
                          SPOData(spo2: 96.73, date: "2025-10-22T00:00:00"),
                          SPOData(spo2: 95.18, date: "2025-10-21T00:00:00"),
                          SPOData(spo2: 93.94, date: "2025-10-20T00:00:00"),
                          SPOData(spo2: 97.67, date: "2025-10-19T00:00:00"),
                          SPOData(spo2: 94.89, date: "2025-10-18T00:00:00"),
                          SPOData(spo2: 96.11, date: "2025-10-17T00:00:00"),
                          SPOData(spo2: 96.9, date: "2025-10-16T00:00:00"),
                          SPOData(spo2: 96.5, date: "2025-10-15T00:00:00"),
                          SPOData(spo2: 92.77, date: "2025-10-14T00:00:00"),
                          SPOData(spo2: 94.3, date: "2025-10-13T00:00:00"),
                          SPOData(spo2: 96.75, date: "2025-10-12T00:00:00"),
                          SPOData(spo2: 98.33, date: "2025-10-09T00:00:00"),
                          SPOData(spo2: 97.0, date: "2025-10-08T00:00:00"),
                          SPOData(spo2: 96.29, date: "2025-10-07T00:00:00"),
                          SPOData(spo2: 93.58, date: "2025-10-06T00:00:00"),
                          SPOData(spo2: 93.0, date: "2025-10-05T00:00:00"),
                          SPOData(spo2: 97.75, date: "2025-10-04T00:00:00"),
                          SPOData(spo2: 94.86, date: "2025-10-03T00:00:00"),
                          SPOData(spo2: 95.58, date: "2025-10-02T00:00:00"),
                          SPOData(spo2: 94.22, date: "2025-10-01T00:00:00"),
                          SPOData(spo2: 98.0, date: "2025-09-30T00:00:00"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
