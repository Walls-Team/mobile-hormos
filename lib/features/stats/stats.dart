import 'package:flutter/material.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/features/stats/components/sleep_duration_chart.dart';
import 'package:genius_hormo/features/stats/components/sleep_efficiency_bar_chart.dart';
import 'package:genius_hormo/features/stats/components/sleep_interruptions_stat_chart.dart';
import 'package:genius_hormo/features/stats/components/heart_rate_resting_chart.dart';
import 'package:genius_hormo/features/stats/components/spo2_chart.dart';
import 'package:genius_hormo/features/stats/components/calories_burned_chart.dart';
import 'package:genius_hormo/features/stats/dto/dtos.dart';
import 'package:genius_hormo/features/stats/service/stats_service.dart';
import 'package:get_it/get_it.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';

enum TimeFilter { oneWeek, twoWeeks, threeWeeks, fourWeeks }

class StatsScreen extends StatefulWidget {
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final StatsService _statsService = GetIt.instance<StatsService>();
  final UserStorageService _userStorageService =
      GetIt.instance<UserStorageService>();

  late Future<AllStats> _statsFuture;
  TimeFilter _currentFilter = TimeFilter.fourWeeks;

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadAllStats();
  }

  Future<AllStats> _loadAllStats() async {
    final token = await _userStorageService.getJWTToken();
    if (token == null || token.isEmpty) {
      throw Exception('No token available');
    }
    return _statsService.getAllStatsParallel(token: token);
  }

  Future<void> _refreshStats() async {
    setState(() {
      _statsFuture = _loadAllStats();
    });
  }

  void _changeFilter(bool forward) {
    setState(() {
      final index = TimeFilter.values.indexOf(_currentFilter);
      if (forward && index < TimeFilter.values.length - 1) {
        _currentFilter = TimeFilter.values[index + 1];
      } else if (!forward && index > 0) {
        _currentFilter = TimeFilter.values[index - 1];
      }
    });
  }

  void _selectFilter(TimeFilter filter) {
    setState(() {
      _currentFilter = filter;
    });
  }

  List<T> _filterDataByWeeks<T>(List<T> data, DateTime Function(T) getDate) {
    final now = DateTime.now();
    final weeks = _getWeeksForFilter(_currentFilter);
    final cutoffDate = now.subtract(Duration(days: 7 * weeks));

    return data.where((item) {
      final date = getDate(item);
      return date.isAfter(cutoffDate) || date.isAtSameMomentAs(cutoffDate);
    }).toList();
  }

  int _getWeeksForFilter(TimeFilter filter) {
    switch (filter) {
      case TimeFilter.oneWeek:
        return 1;
      case TimeFilter.twoWeeks:
        return 2;
      case TimeFilter.threeWeeks:
        return 3;
      case TimeFilter.fourWeeks:
        return 4;
    }
  }

  String _getFilterLabel(TimeFilter filter) {
    final locale = Localizations.localeOf(context);
    final isEnglish = locale.languageCode == 'en';
    final weekSymbol = isEnglish ? 'w' : 's';
    
    switch (filter) {
      case TimeFilter.oneWeek:
        return '1$weekSymbol';
      case TimeFilter.twoWeeks:
        return '2$weekSymbol';
      case TimeFilter.threeWeeks:
        return '3$weekSymbol';
      case TimeFilter.fourWeeks:
        return '4$weekSymbol';
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return FutureBuilder<AllStats>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return RefreshIndicator(
            onRefresh: _refreshStats,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height - 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.engineering, size: 64, color: Colors.orange),
                      SizedBox(height: 16),
                      Text(
                        localizations['statsScreen']['errorLoading'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        localizations['statsScreen']['maintenanceMessage'],
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 16),
                      Text(
                        localizations['statsScreen']['pullToRetry'],
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          return RefreshIndicator(
            onRefresh: _refreshStats,
            child: _buildContent(snapshot.data!),
          );
        }

        return Center(child: Text(localizations['statsScreen']['couldNotLoad']));
      },
    );
  }

  Widget _buildContent(AllStats allStats) {
    // Filtrar datos según el periodo seleccionado
    final filteredEfficiency = _filterDataByWeeks<SleepEfficiencyRecord>(
        allStats.sleepEfficiency.records, (r) => r.date);
    final filteredDuration =
        _filterDataByWeeks<SleepDurationRecord>(allStats.sleepDuration.records, (r) => r.date);
    final filteredInterruptions = _filterDataByWeeks<SleepInterruptionRecord>(
        allStats.sleepInterruptions.records, (r) => r.date);
    final filteredHeartRate = _filterDataByWeeks<HeartRateRecord>(
        allStats.heartRate.records, (r) => r.date);
    final filteredSpo2 =
        _filterDataByWeeks<Spo2Record>(allStats.spo2.records, (r) => r.date);
    final filteredCalories =
        _filterDataByWeeks<CalorieRecord>(allStats.calories.records, (r) => r.date);

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Header con filtros
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!['statsScreen']['sleep'],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Filtros de tiempo con flechas
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Flechas de navegación
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, size: 20),
                    onPressed: () => _changeFilter(false),
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right, size: 20),
                    onPressed: () => _changeFilter(true),
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ],
              ),
            ),

            // Botones de semanas
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.all(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: TimeFilter.values.map((filter) {
                  final isSelected = filter == _currentFilter;
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 2),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _selectFilter(filter),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _getFilterLabel(filter),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Gráfico 1: Sleep Efficiency
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SleepEfficiencyBarChart(data: filteredEfficiency),
          ),
        ),
        const SizedBox(height: 16),

        // Gráfico 2: Sleep Duration
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SleepDurationChart(data: filteredDuration),
          ),
        ),
        const SizedBox(height: 16),

        // Gráfico 3: Sleep Interruptions
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SleepInterruptionsStatChart(data: filteredInterruptions),
          ),
        ),
        const SizedBox(height: 40),

        // ========== NUEVA SECCIÓN: Recovery & nervous system ==========
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                AppLocalizations.of(context)!['statsScreen']['recoveryNervous'],
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width < 360 ? 18 : 22,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Filtros de tiempo con flechas (mismo componente)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Flechas de navegación
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, size: 20),
                    onPressed: () => _changeFilter(false),
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right, size: 20),
                    onPressed: () => _changeFilter(true),
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ],
              ),
            ),

            // Botones de semanas
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.all(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: TimeFilter.values.map((filter) {
                  final isSelected = filter == _currentFilter;
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 2),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _selectFilter(filter),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _getFilterLabel(filter),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Gráfico 4: Heart Rate Resting
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: HeartRateRestingChart(data: filteredHeartRate),
          ),
        ),
        const SizedBox(height: 16),

        // Gráfico 5: SpO2
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Spo2Chart(data: filteredSpo2),
          ),
        ),
        const SizedBox(height: 40),

        // ========== NUEVA SECCIÓN: Activity and context ==========
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!['statsScreen']['activityContext'],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Filtros de tiempo con flechas
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Flechas de navegación
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, size: 20),
                    onPressed: () => _changeFilter(false),
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right, size: 20),
                    onPressed: () => _changeFilter(true),
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ],
              ),
            ),

            // Botones de semanas
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.all(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: TimeFilter.values.map((filter) {
                  final isSelected = filter == _currentFilter;
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 2),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _selectFilter(filter),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _getFilterLabel(filter),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Gráfico 6: Calories Burned
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CaloriesBurnedChart(data: filteredCalories),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
