import 'package:flutter/material.dart';
import 'package:genius_hormo/views/dashboard/components/progress_bar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SleepChart extends StatelessWidget {
  final List<REMData> data;
  const SleepChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      spacing: 8.0,
      children: [
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'REM',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'REM Avg: ${_calculateAverageDuration()}h',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Stack(
          children: [
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  majorGridLines: MajorGridLines(
                    width: 0,
                    color: theme.colorScheme.onSurface.withAlpha(100),
                    dashArray: <double>[1, 1], // Líneas punteadas
                  ),
                  axisLine: AxisLine(
                    width: 1,
                    color: theme.colorScheme.onSurface,
                  ),
                  labelStyle: theme.textTheme.bodySmall!.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                primaryYAxis: NumericAxis(
                  majorGridLines: MajorGridLines(
                    width: 1,
                    color: theme.colorScheme.onSurface.withAlpha(100),
                    dashArray: <double>[1, 1], // Líneas punteadas
                  ),
                  axisLine: AxisLine(
                    width: 1,
                    color: theme.colorScheme.onSurface,
                  ),
                  labelStyle: theme.textTheme.bodySmall!.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                trackballBehavior: TrackballBehavior(
                  enable: true,
                  activationMode: ActivationMode.singleTap,
                  tooltipDisplayMode: TrackballDisplayMode.nearestPoint,
                  tooltipSettings: const InteractiveTooltip(
                    enable: true,
                    format: 'point.x\n REM duration: point.y',
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
                // tooltipBehavior: _tooltipBehavior,
                series: <CartesianSeries<REMData, String>>[
                  ColumnSeries<REMData, String>(
                    dataSource: data, // Cambiado de widget.data a data
                    xValueMapper: (REMData data, _) => _formatDate(data.date),
                    yValueMapper: (REMData data, _) => data.sleepDurationRem,
                    pointColorMapper: (REMData data, _) =>
                        Theme.of(context).colorScheme.error,
                    width: 1.0,
                    spacing: 0.1,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const ProgressBar(progress: 50),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      final months = [
        'ene',
        'feb',
        'mar',
        'abr',
        'may',
        'jun',
        'jul',
        'ago',
        'sep',
        'oct',
        'nov',
        'dic',
      ];
      return '${months[date.month - 1]} ${date.day}';
    } catch (e) {
      return dateString;
    }
  }

  String _calculateAverageDuration() {
    if (data.isEmpty) return "0.0"; // Cambiado de widget.data a data
    final total = data.fold(
      // Cambiado de widget.data a data
      0.0,
      (sum, data) => sum + data.sleepDurationRem,
    );
    return (total / data.length).toStringAsFixed(
      1,
    ); // Cambiado de widget.data a data
  }
}

class REMData {
  final double sleepDurationRem;
  final String date;

  REMData({
    required this.sleepDurationRem,
    required this.date,
  });
}
