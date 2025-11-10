import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TestosteroneChart extends StatelessWidget {
  final List<ChartData> energyData;

  const TestosteroneChart({super.key, required this.energyData});

  @override
  Widget build(BuildContext context) {

    final colorScheme = Theme.of(context).colorScheme; 

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
                    'Testosterone Estimate',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    softWrap: true,
                  ),
                ),
                Expanded(
                  flex: 2, // Ocupa 1 parte del espacio disponible
                  child: Text(
                    'Last updated: Nov 03, 2025',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.right,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              SizedBox(
                height: 400, // Altura fija para el gráfico
                child: Center(
                  child: SfCircularChart(
                    annotations: <CircularChartAnnotation>[
                      CircularChartAnnotation(
                        widget: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Current', style: TextStyle(fontSize: 14)),
                            Text(
                              '97',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('ng/dL', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ],

                    legend: Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                      overflowMode: LegendItemOverflowMode.wrap,
                      orientation: LegendItemOrientation.horizontal,
                      toggleSeriesVisibility:
                          true, // Permite ocultar/mostrar series
                      legendItemBuilder:
                          (
                            String name,
                            dynamic series,
                            dynamic point,
                            int index,
                          ) {
                            final data = energyData[index];
                            return Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              padding: EdgeInsets.all(6),

                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: data.color,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    '${data.mes}: ${data.valor}%',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                    ),
                    series: <CircularSeries>[
                      RadialBarSeries<ChartData, String>(
                        dataSource: energyData,
                        xValueMapper: (ChartData data, _) => data.mes,
                        yValueMapper: (ChartData data, _) => data.valor,
                        pointColorMapper: (ChartData data, _) => data.color,
                        maximumValue: 100,
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

              // Información flotante al lado de la barra seleccionada
            ],
          ),

          const SizedBox(height: 16),

          Text(
            'This is not a medical diagnosis. For accurate results, please consult your doctor or a certified laboratory.',
            style: TextStyle(fontSize: 10, color: colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


class ChartData {
  final String mes;
  final double valor;
  final Color color;

  ChartData(this.mes, this.valor, this.color);
}

