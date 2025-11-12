import 'package:flutter/material.dart';
import 'package:genius_hormo/features/stats/dto/dtos.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class HeartRateRestingChart extends StatelessWidget {
  final List<HeartRateRecord> data;

  const HeartRateRestingChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Filtrar solo los registros con heartRateResting no nulo
    final validData = data
        .where((record) => record.heartRateResting != null)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final ThemeData theme = Theme.of(context);
    final avgHeartRate = _calculateAverage(validData);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'heartrate Resting',
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
              interval: _calculateXAxisInterval(validData.length),
            ),
            primaryYAxis: NumericAxis(
              minimum: _calculateYAxisMin(validData),
              maximum: _calculateYAxisMax(validData),
              interval: 20,
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
                format: 'point.x\npoint.y bpm',
                color: Colors.black,
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            series: <CartesianSeries>[
              ColumnSeries<HeartRateRecord, String>(
                dataSource: validData,
                xValueMapper: (HeartRateRecord data, int index) =>
                    _formatDate(data.date),
                yValueMapper: (HeartRateRecord data, int index) =>
                    data.heartRateResting,
                color: const Color(0xFF00D9FF),
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
    return DateFormat('h:mma').format(date).toLowerCase();
  }

  double _calculateXAxisInterval(int dataLength) {
    if (dataLength <= 5) return 1;
    if (dataLength <= 10) return 2;
    return (dataLength / 5).ceilToDouble();
  }

  double _calculateYAxisMin(List<HeartRateRecord> data) {
    if (data.isEmpty) return 60;
    final minRate = data
        .map((e) => e.heartRateResting ?? 60)
        .reduce((a, b) => a < b ? a : b);
    return (minRate * 0.8).floorToDouble();
  }

  double _calculateYAxisMax(List<HeartRateRecord> data) {
    if (data.isEmpty) return 100;
    final maxRate = data
        .map((e) => e.heartRateResting ?? 100)
        .reduce((a, b) => a > b ? a : b);
    return (maxRate * 1.2).ceilToDouble();
  }

  double _calculateAverage(List<HeartRateRecord> data) {
    if (data.isEmpty) return 0;
    final validRecords =
        data.where((e) => e.heartRateResting != null).toList();
    if (validRecords.isEmpty) return 0;
    final total = validRecords
        .map((e) => e.heartRateResting!)
        .reduce((a, b) => a + b);
    return total / validRecords.length;
  }
}
