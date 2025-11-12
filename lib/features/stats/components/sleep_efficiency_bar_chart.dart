import 'package:flutter/material.dart';
import 'package:genius_hormo/features/stats/dto/dtos.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class SleepEfficiencyBarChart extends StatelessWidget {
  final List<SleepEfficiencyRecord> data;

  const SleepEfficiencyBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final sortedData = List<SleepEfficiencyRecord>.from(data)
      ..sort((a, b) => a.date.compareTo(b.date));

    final ThemeData theme = Theme.of(context);
    final avgEfficiency = _calculateAverage(sortedData);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sleep Efficiency',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(Icons.info_outline, size: 20, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Keep testing at this intensity to maintain optimal hormonal output',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: SfCartesianChart(
            margin: EdgeInsets.zero,
            plotAreaBorderWidth: 0,
            primaryXAxis: CategoryAxis(
              majorGridLines: const MajorGridLines(width: 0),
              axisLine: const AxisLine(width: 0),
              labelStyle: const TextStyle(fontSize: 10),
            ),
            primaryYAxis: NumericAxis(
              minimum: 0,
              maximum: 100,
              interval: 25,
              majorGridLines: MajorGridLines(
                width: 1,
                color: theme.colorScheme.onSurface.withAlpha(50),
                dashArray: <double>[2, 2],
              ),
              axisLine: const AxisLine(width: 0),
              labelStyle: const TextStyle(fontSize: 10),
              majorTickLines: const MajorTickLines(size: 0),
            ),
            trackballBehavior: TrackballBehavior(
              enable: true,
              activationMode: ActivationMode.singleTap,
              tooltipDisplayMode: TrackballDisplayMode.nearestPoint,
              tooltipSettings: const InteractiveTooltip(
                enable: true,
                format: 'point.x\npoint.y%',
                color: Colors.black,
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            series: <CartesianSeries>[
              ColumnSeries<SleepEfficiencyRecord, String>(
                dataSource: sortedData,
                xValueMapper: (SleepEfficiencyRecord data, int index) =>
                    _formatDate(data.date),
                yValueMapper: (SleepEfficiencyRecord data, int index) =>
                    data.sleepEfficiency,
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
                spacing: 0.2,
                width: 0.6,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('d').format(date);
  }

  double _calculateAverage(List<SleepEfficiencyRecord> data) {
    if (data.isEmpty) return 0;
    final total =
        data.map((e) => e.sleepEfficiency).reduce((a, b) => a + b);
    return total / data.length;
  }
}
