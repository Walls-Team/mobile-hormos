import 'package:flutter/material.dart';
import 'package:genius_hormo/features/stats/dto/dtos.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';

class SleepDurationChart extends StatelessWidget {
  final List<SleepDurationRecord> data;

  const SleepDurationChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final sortedData = List<SleepDurationRecord>.from(data)
      ..sort((a, b) => a.date.compareTo(b.date));

    final ThemeData theme = Theme.of(context);
    final avgDuration = _calculateAverage(sortedData);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                AppLocalizations.of(context)!['statsScreen']['sleepDuration'] ?? 'Sleep Duration',
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
              minimum: 0,
              maximum: _calculateYAxisMax(sortedData),
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
                format: 'point.x\npoint.y ${AppLocalizations.of(context)!['statsScreen']['hours'] ?? 'h'}',
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
              LineSeries<SleepDurationRecord, String>(
                dataSource: sortedData,
                xValueMapper: (SleepDurationRecord data, int index) =>
                    _formatDate(data.date),
                yValueMapper: (SleepDurationRecord data, int index) =>
                    data.sleepDuration,
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
              AreaSeries<SleepDurationRecord, String>(
                dataSource: sortedData,
                xValueMapper: (SleepDurationRecord data, int index) =>
                    _formatDate(data.date),
                yValueMapper: (SleepDurationRecord data, int index) =>
                    data.sleepDuration,
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
    final month = DateFormat('MMM').format(date).toLowerCase();
    final day = date.day;
    return '$day';
  }

  double _calculateYAxisMax(List<SleepDurationRecord> data) {
    if (data.isEmpty) return 10;
    final maxDuration =
        data.map((e) => e.sleepDuration).reduce((a, b) => a > b ? a : b);
    return (maxDuration * 1.2).ceilToDouble();
  }

  double _calculateAverage(List<SleepDurationRecord> data) {
    if (data.isEmpty) return 0;
    final total = data.map((e) => e.sleepDuration).reduce((a, b) => a + b);
    return total / data.length;
  }
}
