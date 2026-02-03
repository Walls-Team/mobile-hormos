import 'package:flutter/material.dart';
import 'package:genius_hormo/features/dashboard/dto/energy_levels/energy_stats.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';

class TestosteroneChart extends StatelessWidget {
  final EnergyStats energyData;
  final List<ChartData> chartData;
  final int currentValue;
  // final int maximumValue;
  final String lastUpdated;

  TestosteroneChart({
    super.key,
    required this.energyData,
    required this.lastUpdated,
  }) : chartData = _calculateChartData(energyData),
       currentValue = energyData.currentLevel.round();
  // lastUpdated = _formatLastUpdated();

  static List<ChartData> _calculateChartData(EnergyStats stats) {
    return [
      ChartData('Lowest Level', stats.lowestLevel, Colors.green),
      ChartData('Weekly Average', stats.averageLevel, Colors.yellow),
      ChartData('Highest Level', stats.highestLevel, Colors.greenAccent),
      ChartData('Current Level', stats.currentLevel, Colors.cyan),
    ];
  }

  List<ChartData> _getLocalizedChartData(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return [
      ChartData(localizations['dashboard']['lowestLevel'] ?? 'Lowest Level', energyData.lowestLevel, Colors.green),
      ChartData(localizations['dashboard']['weeklyAverage'] ?? 'Weekly Average', energyData.averageLevel, Colors.yellow),
      ChartData(localizations['dashboard']['highestLevel'] ?? 'Highest Level', energyData.highestLevel, Colors.greenAccent),
      ChartData(localizations['dashboard']['currentLevel'] ?? 'Current Level', energyData.currentLevel, Colors.cyan),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  flex: 3, // Ocupa 2 partes del espacio disponible
                  child: Text(
                    AppLocalizations.of(context)!['dashboard']['testosteroneEstimate'],
                    softWrap: true,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width < 360 ? 16 : 20,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                Expanded(
                  flex: 2, // Ocupa 1 parte del espacio disponible
                  child: Text(
                    "${AppLocalizations.of(context)!['dashboard']['lastUpdated']}:\n ${DateFormat.yMMMd().format(DateTime.parse(lastUpdated))}",
                    textAlign: TextAlign.right,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: 300, // Altura fija para el gráfico
                child: Center(
                  child: SfCircularChart(
                    annotations: <CircularChartAnnotation>[
                      CircularChartAnnotation(
                        widget: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(localizations['dashboardScreen']['current'], style: TextStyle(fontSize: 14)),
                            Text(
                              '$currentValue',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(localizations['dashboardScreen']['ngdl'], style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ],

                    series: <CircularSeries>[
                      RadialBarSeries<ChartData, String>(
                        dataSource: _getLocalizedChartData(context),
                        xValueMapper: (ChartData data, _) => data.stat,
                        yValueMapper: (ChartData data, _) => data.valor,
                        pointColorMapper: (ChartData data, _) => data.color,
                        maximumValue: 1400,
                        innerRadius: '50%',
                        radius: '80%',
                        gap: '5%',
                        cornerStyle: CornerStyle.bothCurve,
                        trackColor: Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ),

              _buildChartLegend(context),

              // Información flotante al lado de la barra seleccionada
            ],
          ),

          const SizedBox(height: 16),

          Text(
            AppLocalizations.of(context)!['dashboard']['medicalDisclaimer'],
            style: TextStyle(fontSize: 10, color: colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(BuildContext context) {
    final localizedChartData = _getLocalizedChartData(context);
    return Container(
      child: GridView.builder(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(), // Deshabilita el scroll interno
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 columnas
          crossAxisSpacing: 8, // Espacio horizontal entre items
          mainAxisSpacing: 4, // Espacio vertical entre items
          childAspectRatio: 3, // Relación ancho/alto de cada item
        ),
        itemCount: localizedChartData.length, // Número total de items
        itemBuilder: (context, index) {
          final data = localizedChartData[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: data.color,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${data.stat}:\n${data.valor.toStringAsFixed(1)}ng/dL',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ChartData {
  final String stat;
  final double valor;
  final Color color;

  ChartData(this.stat, this.valor, this.color);
}
