import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:genius_hormo/core/api/api_helpers.dart';
import 'package:genius_hormo/core/config/app_config.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/features/dashboard/dto/basic_metrics/sleep_data_dto.dart';
import 'package:genius_hormo/features/dashboard/dto/energy_levels/energy_data.dart';
import 'package:genius_hormo/features/dashboard/dto/health_data.dart';
import 'package:http/http.dart' as http;

class DashBoardService {
  final UserStorageService _storageService;
  final http.Client _client;

  DashBoardService({UserStorageService? storageService, http.Client? client})
    : _storageService = storageService ?? UserStorageService(),
      _client = client ?? http.Client();

  Future<SleepData> getBasicMetrics({required String token}) async {
    final url = AppConfig.getApiUrl('home/basic-metrics');
    
    debugPrint('🚀 GET BASIC METRICS REQUEST');
    debugPrint('📍 URL: $url');

    final result = await executeRequest<SleepData>(
      request: _client
          .get(
            Uri.parse(url),
            headers: AppConfig.getCommonHeaders(withAuth: true, token: token),
          )
          .timeout(AppConfig.defaultTimeout),
      fromJson: SleepData.fromJson,
    );

    if (!result.success || result.data == null) {
      throw Exception(result.message);
    }
    return result.data!;
  }

  Future<EnergyData> getEnergyLevels({required String token}) async {
    final url = AppConfig.getApiUrl('home/energy-levels');
    
    debugPrint('🚀 GET ENERGY LEVELS REQUEST');
    debugPrint('📍 URL: $url');

    final result = await executeRequest<EnergyData>(
      request: _client
          .get(
            Uri.parse(url),
            headers: AppConfig.getCommonHeaders(withAuth: true, token: token),
          )
          .timeout(AppConfig.defaultTimeout),
      fromJson: EnergyData.fromJson,
    );

    if (!result.success || result.data == null) {
      throw Exception(result.message);
    }
    return result.data!;
  }

  Future<HealthData> getHealthData({required String token}) async {
    try {
      final results = await Future.wait([
        getBasicMetrics(token: token).catchError((e) {
          debugPrint('⚠️ Error en basic-metrics, usando datos vacíos: $e');
          return SleepData.empty();
        }),
        getEnergyLevels(token: token).catchError((e) {
          debugPrint('⚠️ Error en energy-levels, usando datos vacíos: $e');
          return EnergyData.empty();
        }),
      ]);

      return HealthData(
        sleep: results[0] as SleepData,
        energy: results[1] as EnergyData,
      );
    } catch (e) {
      debugPrint('❌ Error general en getHealthData: $e');
      return HealthData.empty();
    }
  }

}
