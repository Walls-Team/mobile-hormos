import 'package:flutter/material.dart';
import 'package:genius_hormo/features/dashboard/components/progress_bar.dart';
import 'package:genius_hormo/features/dashboard/dto/basic_metrics/rem_sleep_record_dto.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';

class RemChart extends StatelessWidget {
  final List<RemSleepRecord> data;
  const RemChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Column(
      spacing: 8.0,
      children: [
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations['dashboard']['rem'] ?? 'REM',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text('${localizations['dashboardScreen']['remAvg']}: ${_calculateAverageDuration()}h', softWrap: true),
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
                  tooltipSettings: InteractiveTooltip(
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
                series: <CartesianSeries<RemSleepRecord, String>>[
                  ColumnSeries<RemSleepRecord, String>(
                    dataSource: data, // Cambiado de widget.data a data
                    xValueMapper: (RemSleepRecord data, _) =>
                        _formatDate(data.date),
                    yValueMapper: (RemSleepRecord data, _) =>
                        data.sleepDurationRem,
                    pointColorMapper: (RemSleepRecord data, _) =>
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

  REMData({required this.sleepDurationRem, required this.date});
}
