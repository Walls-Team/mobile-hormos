import 'package:flutter/material.dart';
import 'package:genius_hormo/features/dashboard/dto/basic_metrics/spo2_record_dto.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SPO2Chart extends StatelessWidget {
  final List<SpO2Record> data;

  const SPO2Chart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SPO',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              // Se eliminó el texto 'Avg:' según petición del cliente
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

                // primaryYAxis: ChartThemes.primaryYAxis(context),
                trackballBehavior: TrackballBehavior(
                  enable: true,
                  activationMode: ActivationMode.singleTap,
                  tooltipDisplayMode: TrackballDisplayMode.nearestPoint,
                  tooltipSettings: const InteractiveTooltip(
                    enable: true,
                    format: 'point.x\nSpO2: point.y ',
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
                series: <CartesianSeries<SpO2Record, String>>[
                  ColumnSeries<SpO2Record, String>(
                    dataSource: data, // Cambiado de widget.data a data
                    xValueMapper: (SpO2Record data, _) => _formatDate(data.date),
                    yValueMapper: (SpO2Record data, _) => data.spo2,

                    pointColorMapper: (SpO2Record data, _) =>
                        Theme.of(context).colorScheme.primary,
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
}

