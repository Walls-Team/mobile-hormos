import 'package:flutter/material.dart';
import 'package:genius_hormo/theme/colors_pallete.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';

class SleepSummaryChart extends StatelessWidget {
  final int interruptions;
  final double efficiency;
  final double duration;
  final int sleepScore;

  const SleepSummaryChart({
    super.key,
    required this.interruptions,
    required this.efficiency,
    required this.duration,
    required this.sleepScore,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        spacing: 8.0,
        children: [
          Container(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // ← Esta es la clave
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Summary',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                Text(localizations['dashboardScreen']['sleepScoreEfficiency']),
              ],
            ),
          ),

          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: SfCircularChart(
                  margin: EdgeInsets.zero,
                  annotations: <CircularChartAnnotation>[
                    CircularChartAnnotation(
                      widget: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Duration',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            '${duration.toStringAsFixed(0)}h',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  series: <CircularSeries>[
                    DoughnutSeries<ChartData, String>(
                      dataSource: [
                        ChartData('Efficency', efficiency, neutral_400),
                        ChartData(
                          'Remaining',
                          (100 - efficiency).toDouble(),
                          Theme.of(context).colorScheme.error,
                        ),
                      ],
                      xValueMapper: (ChartData data, _) => data.category,
                      yValueMapper: (ChartData data, _) => data.value,
                      pointColorMapper: (ChartData data, _) => data.color,
                      cornerStyle: CornerStyle.bothCurve,
                      innerRadius: '85%',
                      radius: '100%',

                      // cornerStyle: CornerStyle.bothCurve,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatItem(
                      'Duration',
                      '${duration.toStringAsFixed(1)}h',
                    ),
                    const SizedBox(height: 12),
                    _buildStatItem('Interruptions', '$interruptions'),
                    const SizedBox(height: 12),
                    _buildStatItem(
                      'Efficiency',
                      '${efficiency.toStringAsFixed(0)}%',
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                          strokeAlign: BorderSide.strokeAlignCenter,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),

                      child: _buildStatItem(
                        'Sleep Score',
                        '${sleepScore.toStringAsFixed(0)}%',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Gráfico circular a la izquierda  )

          // Gráfico circular a la izquierda
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 14)),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class ChartData {
  final String category;
  final double value;
  final Color color;

  ChartData(this.category, this.value, this.color);
}
