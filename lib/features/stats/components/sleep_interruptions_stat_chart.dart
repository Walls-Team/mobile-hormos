import 'package:flutter/material.dart';
import 'package:genius_hormo/features/stats/dto/dtos.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class SleepInterruptionsStatChart extends StatelessWidget {
  final List<SleepInterruptionRecord> data;

  const SleepInterruptionsStatChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final sortedData = List<SleepInterruptionRecord>.from(data)
      ..sort((a, b) => a.date.compareTo(b.date));

    final ThemeData theme = Theme.of(context);
    final avgInterruptions = _calculateAverage(sortedData);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sleep Interruptions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(Icons.info_outline, size: 20, color: Colors.grey),
          ],
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
              maximum: _calculateYAxisMax(sortedData),
              interval: _calculateYAxisInterval(sortedData),
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
                format: 'point.x\npoint.y interruptions',
                color: Colors.black,
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              lineType: TrackballLineType.vertical,
              lineColor: Colors.grey,
              lineWidth: 1,
              markerSettings: const TrackballMarkerSettings(
                markerVisibility: TrackballVisibilityMode.visible,
                height: 6,
                width: 6,
                borderWidth: 2,
                color: Colors.white,
              ),
            ),
            series: <CartesianSeries>[
              LineSeries<SleepInterruptionRecord, String>(
                dataSource: sortedData,
                xValueMapper: (SleepInterruptionRecord data, int index) =>
                    _formatDate(data.date),
                yValueMapper: (SleepInterruptionRecord data, int index) =>
                    data.sleepInterruptions,
                color: const Color(0xFF00D9FF),
                width: 3,
                markerSettings: const MarkerSettings(
                  isVisible: true,
                  height: 6,
                  width: 6,
                  borderWidth: 2,
                  color: Color(0xFF00D9FF),
                  borderColor: Color(0xFF00D9FF),
                ),
              ),
              AreaSeries<SleepInterruptionRecord, String>(
                dataSource: sortedData,
                xValueMapper: (SleepInterruptionRecord data, int index) =>
                    _formatDate(data.date),
                yValueMapper: (SleepInterruptionRecord data, int index) =>
                    data.sleepInterruptions,
                color: const Color(0xFF00D9FF).withOpacity(0.2),
                borderColor: Colors.transparent,
                enableTooltip: false,
                markerSettings: const MarkerSettings(isVisible: false),
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

  double _calculateYAxisMax(List<SleepInterruptionRecord> data) {
    if (data.isEmpty) return 15;
    final maxInterruptions = data
        .map((e) => e.sleepInterruptions)
        .reduce((a, b) => a > b ? a : b);
    return (maxInterruptions * 1.2).ceilToDouble();
  }

  double _calculateYAxisInterval(List<SleepInterruptionRecord> data) {
    final max = _calculateYAxisMax(data);
    if (max <= 8) return 2;
    if (max <= 16) return 4;
    return 5;
  }

  double _calculateAverage(List<SleepInterruptionRecord> data) {
    if (data.isEmpty) return 0;
    final total =
        data.map((e) => e.sleepInterruptions).reduce((a, b) => a + b);
    return total / data.length;
  }
}
