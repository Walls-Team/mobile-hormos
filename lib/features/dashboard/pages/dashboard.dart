import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/features/dashboard/components/rem_chart.dart';
import 'package:genius_hormo/features/dashboard/components/sleep_interruptions_chart.dart';
import 'package:genius_hormo/features/dashboard/components/spo_chart.dart';
import 'package:genius_hormo/features/dashboard/components/stats.dart';
import 'package:genius_hormo/features/dashboard/components/testosterone_chart.dart';
import 'package:genius_hormo/features/dashboard/dto/basic_metrics/rem_sleep_record_dto.dart';
import 'package:genius_hormo/features/dashboard/dto/basic_metrics/sleep_record_dto.dart';
import 'package:genius_hormo/features/dashboard/dto/basic_metrics/sleep_summary_dto.dart';
import 'package:genius_hormo/features/dashboard/dto/basic_metrics/spo2_record_dto.dart';
import 'package:genius_hormo/features/dashboard/dto/energy_levels/energy_stats.dart';
import 'package:genius_hormo/features/dashboard/dto/health_data.dart';
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
  late Future<HealthData> _metricsFuture;

  @override
  void initState() {
    super.initState();
    // ✅ SE EJECUTA UNA SOLA VEZ al cargar la página
    _metricsFuture = _loadMetrics();
  }

  Future<HealthData> _loadMetrics() async {
    final token = await _userStorageService.getJWTToken();
    return _dashboardService.getHealthData(token: token!);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HealthData>(
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
          return _buildCharts(snapshot.data!);
        }

        return Center(child: Text('No se pudieron cargar los datos'));
      },
    );
  }

  Widget _buildCharts(HealthData metrics) {
    return ListView(
      padding: EdgeInsets.all(12),
      children: [
        _buildTestosteroneChart(
          stats: metrics.energy.stats,
          lastUpdated: metrics.sleep.dates.first,
        ),
        _buildStatsCards(resume: metrics.sleep.resume),
        _buildRemChart(remData: metrics.sleep.remResume),
        _buildSleepInterruptionsChart(
          sleepInterruptionsData: metrics.sleep.sleepResume,
        ),
        _buildSpO2Chart(spO2ChartData: metrics.sleep.spoResume),
      ],
    );
  }

  Widget _buildTestosteroneChart({
    required EnergyStats stats,
    required String lastUpdated,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TestosteroneChart(energyData: stats, lastUpdated: lastUpdated),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards({required SleepSummary resume}) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: StatCard(
            duration: "${resume.sleepEfficiency}%",
            title: "Sleep\n Efficiency",
            icon: CupertinoIcons.zzz,
          ),
        ),

        Expanded(
          flex: 1,
          child: StatCard(
            duration: "${resume.sleepDuration.round()}h",
            title: "Sleep\n Duration",
            icon: CupertinoIcons.moon,
          ),
        ),
        Expanded(
          flex: 1,
          child: StatCard(
            duration: "${resume.hrvRmssd}",
            title: "Hrv\n rmssd",
            icon: CupertinoIcons.heart,
          ),
        ),
      ],
    );
  }

  Widget _buildRemChart({required List<RemSleepRecord> remData}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: RemChart(data: remData),
      ),
    );
  }

  Widget _buildSleepInterruptionsChart({
    required List<SleepRecord> sleepInterruptionsData,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SleepInterruptionsChart(data: sleepInterruptionsData),
      ),
    );
  }

  Widget _buildSpO2Chart({required List<SpO2Record> spO2ChartData}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SPO2Chart(data: spO2ChartData),
      ),
    );
  }
}
