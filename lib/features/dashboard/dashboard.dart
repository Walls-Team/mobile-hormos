import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/features/dashboard/components/rem_chart.dart';
import 'package:genius_hormo/features/dashboard/components/sleep_interruptions_chart.dart';
import 'package:genius_hormo/features/dashboard/components/spo_chart.dart';
import 'package:genius_hormo/features/dashboard/components/stats.dart';
import 'package:genius_hormo/features/dashboard/components/testosterone_chart.dart';
import 'package:genius_hormo/features/dashboard/dto/basic_metrics/rem_sleep_record_dto.dart';
import 'package:genius_hormo/features/dashboard/dto/basic_metrics/sleep_data_dto.dart';
import 'package:genius_hormo/features/dashboard/dto/basic_metrics/sleep_record_dto.dart';
import 'package:genius_hormo/features/dashboard/dto/basic_metrics/spo2_record_dto.dart';
import 'package:genius_hormo/features/dashboard/services/dashboard_service.dart';
import 'package:get_it/get_it.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashBoardService _dashboardService = GetIt.instance<DashBoardService>();
  final UserStorageService _userStorageService =
      GetIt.instance<UserStorageService>();
  late Future<SleepData> _metricsFuture;

  @override
  void initState() {
    super.initState();
    // ✅ SE EJECUTA UNA SOLA VEZ al cargar la página
    _metricsFuture = _loadMetrics();
  }

  Future<SleepData> _loadMetrics() async {
    final token = await _userStorageService.getJWTToken();
    return _dashboardService.getBasicMetrics(token!);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SleepData>(
      future: _metricsFuture, // ← Se usa la misma instancia del Future
      builder: (context, snapshot) {
        // ⏳ CARGANDO
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // ❌ ERROR
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text('Error al cargar los datos'),
                // ❌ NO hay botón de reintentar porque solo se ejecuta una vez
              ],
            ),
          );
        }

        // ✅ DATOS CARGADOS
        if (snapshot.hasData) {
          // return _buildCharts(snapshot.data!);

          return _buildCharts(snapshot.data!);
        }

        return Center(child: Text('No se pudieron cargar los datos'));
      },
    );
  }

  Widget _buildCharts(SleepData metrics) {
    return ListView(
      padding: EdgeInsets.all(12),
      children: [
        _buildTestosteroneChart(),
        _buildStatsCards(),
        _buildRemChart(metrics.remResume),
        _buildSleepInterruptionsChart(metrics.sleepResume),
        _buildSpO2Chart(metrics.spoResume),
      ],
    );
  }

  Widget _buildTestosteroneChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TestosteroneChart(
              energyData: [
                ChartData('Jan', 75, Colors.blue),
                ChartData('Feb', 85, Colors.green),
                ChartData('Mar', 65, Colors.orange),
                ChartData('Apr', 90, Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: StatCard(
            duration: "92%",
            title: "Sleep\n Efficiency",
            icon: CupertinoIcons.zzz,
          ),
        ),

        Expanded(
          flex: 1,
          child: StatCard(
            duration: "7.9h",
            title: "Sleep\n Duration",
            icon: CupertinoIcons.moon,
          ),
        ),
        Expanded(
          flex: 1,
          child: StatCard(
            duration: "19",
            title: "Hrv\n rmssd",
            icon: CupertinoIcons.heart,
          ),
        ),
      ],
    );
  }

  Widget _buildRemChart(List<RemSleepRecord> remData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: RemChart(data: remData),
      ),
    );
  }

  Widget _buildSleepInterruptionsChart(
    List<SleepRecord> sleepInterruptionsData,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SleepInterruptionsChart(data: sleepInterruptionsData),
      ),
    );
  }

  Widget _buildSpO2Chart(List<SpO2Record> spO2ChartData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SPO2Chart(data: spO2ChartData),
      ),
    );
  }
}
