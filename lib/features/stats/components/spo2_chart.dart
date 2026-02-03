import 'package:flutter/material.dart';
import 'package:genius_hormo/features/stats/dto/dtos.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';

class Spo2Chart extends StatelessWidget {
  final List<Spo2Record> data;

  const Spo2Chart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final sortedData = List<Spo2Record>.from(data)
      ..sort((a, b) => a.date.compareTo(b.date));

    final ThemeData theme = Theme.of(context);
    final avgSpo2 = _calculateAverage(sortedData);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                AppLocalizations.of(context)!['statsScreen']['spo2'] ?? 'SPO2',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width < 360 ? 16 : 20,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
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
              minimum: 88,
              maximum: 100,
              interval: 2,
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
              tooltipSettings: InteractiveTooltip(
                enable: true,
                format: 'point.x\npoint.y%',
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
              LineSeries<Spo2Record, String>(
                dataSource: sortedData,
                xValueMapper: (Spo2Record data, int index) =>
                    _formatDate(data.date),
                yValueMapper: (Spo2Record data, int index) => data.spo2,
                color: const Color(0xFFFFD700), // Amarillo dorado
                width: 3,
                markerSettings: const MarkerSettings(
                  isVisible: true,
                  height: 6,
                  width: 6,
                  borderWidth: 2,
                  color: Color(0xFFFFD700),
                  borderColor: Color(0xFFFFD700),
                ),
              ),
              AreaSeries<Spo2Record, String>(
                dataSource: sortedData,
                xValueMapper: (Spo2Record data, int index) =>
                    _formatDate(data.date),
                yValueMapper: (Spo2Record data, int index) => data.spo2,
                color: const Color(0xFFFFD700).withOpacity(0.2),
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

  double _calculateAverage(List<Spo2Record> data) {
    if (data.isEmpty) return 0;
    final total = data.map((e) => e.spo2).reduce((a, b) => a + b);
    return total / data.length;
  }
}
