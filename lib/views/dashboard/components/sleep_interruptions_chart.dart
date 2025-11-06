import 'package:flutter/material.dart';
import 'package:genius_hormo/views/dashboard/components/sleep_sumary.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class SleepInterruptionsChart extends StatelessWidget {
  final List<SleepData> data;

  const SleepInterruptionsChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Ordenar los datos por fecha (más reciente primero)
    final sortedData = List<SleepData>.from(data)
      ..sort((a, b) => a.date.compareTo(b.date));

    final ThemeData theme = Theme.of(context);

    // Calcular promedios
    final avgInterruptions = _calculateAverageInterruptions(sortedData);
    final avgEfficiency = _calculateAverageEfficiency(sortedData);
    final avgDuration = _calculateAverageDuration(sortedData);
    final avgSleepScore = _calculateAverageSleepScore(sortedData);

    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sleep Interruptions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold, // ← Texto en bold
              ),
            ),
            Text(
              'Avg: ${avgInterruptions.toStringAsFixed(0)}',

              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold, // ← Texto en bold
              ),
            ),
          ],
        ),
        // Gráfico de línea con área
        SizedBox(
          height: 300,
          child: SfCartesianChart(
            margin: EdgeInsets.zero,
            plotAreaBorderWidth: 0,
            primaryXAxis: CategoryAxis(
              majorGridLines: const MajorGridLines(width: 0),
              axisLine: const AxisLine(width: 0),
              labelStyle: const TextStyle(fontSize: 10),
              // majorTickLines: const MajorTickLines(size: 0),
            ),
            primaryYAxis: NumericAxis(
              minimum: 0,
              maximum: _calculateYAxisMax(sortedData),
              interval: _calculateYAxisInterval(sortedData),
              majorGridLines: MajorGridLines(
                width: 1,
                color: theme.colorScheme.onSurface.withAlpha(100),
                dashArray: <double>[1, 1], // Líneas punteadas
              ),
              axisLine: const AxisLine(width: 0),
              labelStyle: const TextStyle(fontSize: 10),
              majorTickLines: const MajorTickLines(size: 0),
            ),

            trackballBehavior: TrackballBehavior(
              enable: true,
              // activationMode: ActivationMode.singleTap,
              activationMode: ActivationMode.singleTap,
              tooltipDisplayMode:
                  TrackballDisplayMode.nearestPoint, // ← Esta línea es clave
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

            series: <CartesianSeries<SleepData, String>>[
              // Línea principal
              LineSeries<SleepData, String>(
                dataSource: sortedData,
                xValueMapper: (SleepData data, _) => _formatDate(data.date),
                yValueMapper: (SleepData data, _) => data.sleepInterruptions,
                color: theme.colorScheme.primary,
                width: 3,

                markerSettings: const MarkerSettings(
                  isVisible: true,
                  height: 4,
                  width: 4,
                  borderWidth: 2,
                ),
              ),
              // Área debajo de la línea
              AreaSeries<SleepData, String>(
                dataSource: sortedData,
                xValueMapper: (SleepData data, _) => _formatDate(data.date),
                yValueMapper: (SleepData data, _) => data.sleepInterruptions,
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                borderColor: Colors.transparent,
                enableTooltip: false, // ← Esto evita el tooltip duplicado
                markerSettings: MarkerSettings(isVisible: false),
              ),
            ],
          ),
        ),

        SleepSummaryChart(
          interruptions: avgInterruptions.toInt(),
          efficiency: avgEfficiency,
          duration: avgDuration,
          sleepScore: avgSleepScore.toInt(),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final month = DateFormat('MMM').format(date).toLowerCase();
    final day = date.day;
    return '$month $day';
  }

  double _calculateYAxisMax(List<SleepData> data) {
    if (data.isEmpty) return 15;
    final maxInterruptions = data
        .map((e) => e.sleepInterruptions)
        .reduce((a, b) => a > b ? a : b);
    // Redondear al siguiente múltiplo de 2 para una escala más limpia
    return (maxInterruptions * 1.2).ceilToDouble().ceilToDouble();
  }

  double _calculateYAxisInterval(List<SleepData> data) {
    final max = _calculateYAxisMax(data);
    if (max <= 8) return 2;
    if (max <= 16) return 4;
    return 5;
  }

  // Métodos para calcular promedios
  double _calculateAverageInterruptions(List<SleepData> data) {
    if (data.isEmpty) return 0;
    final total = data.map((e) => e.sleepInterruptions).reduce((a, b) => a + b);
    return total / data.length;
  }

  double _calculateAverageEfficiency(List<SleepData> data) {
    if (data.isEmpty) return 0;
    final total = data.map((e) => e.sleepEfficiency).reduce((a, b) => a + b);
    return total / data.length;
  }

  double _calculateAverageDuration(List<SleepData> data) {
    if (data.isEmpty) return 0;
    final total = data.map((e) => e.sleepDuration).reduce((a, b) => a + b);
    return total / data.length;
  }

  double _calculateAverageSleepScore(List<SleepData> data) {
    if (data.isEmpty) return 0;
    final total = data.map((e) => e.sleepScore).reduce((a, b) => a + b);
    return total / data.length;
  }
}
class SleepData {
  final double hrvRmssd;
  final double sleepEfficiency;
  final double sleepDuration;
  final int sleepInterruptions;
  final double sleepScore;
  final DateTime date;

  SleepData({
    required this.hrvRmssd,
    required this.sleepEfficiency,
    required this.sleepDuration,
    required this.sleepInterruptions,
    required this.sleepScore,
    required this.date,
  });

  // Constructor desde JSON
  factory SleepData.fromJson(Map<String, dynamic> json) {
    return SleepData(
      hrvRmssd: (json['hrv_rmssd'] as num).toDouble(),
      sleepEfficiency: (json['sleep_efficiency'] as num).toDouble(),
      sleepDuration: (json['sleep_duration'] as num).toDouble(),
      sleepInterruptions: json['sleep_interruptions'] as int,
      sleepScore: (json['sleep_score'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }
}