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
import 'package:genius_hormo/features/stats/dto/dtos.dart';
import 'package:genius_hormo/features/stats/service/stats_service.dart';
import 'package:get_it/get_it.dart';

class StatsScreen extends StatefulWidget {
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final StatsService _statsService = GetIt.instance<StatsService>();
    final UserStorageService _userStorageService =
      GetIt.instance<UserStorageService>();
  late Future<SleepEfficiencyData> _statsFuture;

  @override
  void initState() {
    super.initState();
    // ✅ SE EJECUTA UNA SOLA VEZ al cargar la página
    _statsFuture = _loadMetrics();
  }

  Future<SleepEfficiencyData> _loadMetrics() async {
    final token = await _userStorageService.getJWTToken();
    return _statsService.getSleepEfficiency();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SleepEfficiencyData>(
      future: _statsFuture, // ← Se usa la misma instancia del Future
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

  Widget _buildCharts(SleepEfficiencyData metrics) {
    return ListView(padding: EdgeInsets.all(12), children: [

      ],
    );
  }

  Widget _buildSleepEficiencyChart({required List<SpO2Record> spO2ChartData}) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(16), child: Container()),
    );
  }
}
