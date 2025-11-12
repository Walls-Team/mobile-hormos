import 'package:flutter/material.dart';
import 'package:genius_hormo/features/stats/dto/dtos.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class CaloriesBurnedChart extends StatelessWidget {
  final List<CalorieRecord> data;

  const CaloriesBurnedChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Filtrar solo los registros con calorías no nulas
    final validData = data
        .where((record) => record.caloriesBurned != null)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final ThemeData theme = Theme.of(context);
    final avgCalories = _calculateAverage(validData);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Calories Burned',
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
              minimum: 0,
              maximum: _calculateYAxisMax(validData),
              interval: _calculateYAxisInterval(validData),
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
                format: 'point.x\npoint.y kcal',
                color: Colors.black,
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            series: <CartesianSeries>[
              ColumnSeries<CalorieRecord, String>(
                dataSource: validData,
                xValueMapper: (CalorieRecord data, int index) =>
                    _formatDate(data.date),
                yValueMapper: (CalorieRecord data, int index) =>
                    data.caloriesBurned,
                color: const Color(0xFFFF5722), // Naranja
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

  double _calculateYAxisMax(List<CalorieRecord> data) {
    if (data.isEmpty) return 3000;
    final maxCalories = data
        .map((e) => e.caloriesBurned ?? 0)
        .reduce((a, b) => a > b ? a : b);
    return (maxCalories * 1.2).ceilToDouble();
  }

  double _calculateYAxisInterval(List<CalorieRecord> data) {
    final max = _calculateYAxisMax(data);
    if (max <= 1000) return 200;
    if (max <= 3000) return 500;
    if (max <= 5000) return 1000;
    return 2000;
  }

  double _calculateAverage(List<CalorieRecord> data) {
    if (data.isEmpty) return 0;
    final validRecords =
        data.where((e) => e.caloriesBurned != null).toList();
    if (validRecords.isEmpty) return 0;
    final total = validRecords
        .map((e) => e.caloriesBurned!)
        .reduce((a, b) => a + b);
    return total / validRecords.length;
  }
}
