import 'dart:convert';

import 'package:genius_hormo/core/api/api_helpers.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/features/dashboard/dto/basic_metrics/sleep_data_dto.dart';
import 'package:genius_hormo/features/dashboard/dto/energy_levels/energy_data.dart';
import 'package:genius_hormo/features/dashboard/dto/health_data.dart';
import 'package:http/http.dart' as http;

class DashBoardService {
  static const String _baseUrl = 'http://localhost:3000';
  final UserStorageService _storageService;
  final http.Client _client;

  DashBoardService({UserStorageService? storageService, http.Client? client})
    : _storageService = storageService ?? UserStorageService(),
      _client = client ?? http.Client();

  Future<SleepData> getBasicMetrics({required String token}) async {

    final result = await executeRequest<SleepData>(
      request: _client
          .get(
            Uri.parse('$_baseUrl/v1/api/home/basic-metrics'),
            headers: _getHeaders(withAuth: true, token: token),
          )
          .timeout(const Duration(seconds: 30)),
      fromJson: SleepData.fromJson,
    );

    if (!result.success || result.data == null) {
      throw Exception(result.message);
    }
    return result.data!;
  }

  Future<EnergyData> getEnergyLevels({required String token}) async {

    final result = await executeRequest<EnergyData>(
      request: _client
          .get(
            Uri.parse('$_baseUrl/v1/api/home/energy-levels'),
            headers: _getHeaders(withAuth: true, token: token),
          )
          .timeout(const Duration(seconds: 30)),
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
        getBasicMetrics(token: token),
        getEnergyLevels(token: token),
      ]);

      return HealthData(
        energy: results[1] as EnergyData,
        sleep: results[0] as SleepData,
      );
    } catch (e) {
      throw Exception('error al obtener los datos');
    }
  }

  /// Headers comunes para las requests
  Map<String, String> _getHeaders({bool withAuth = false, String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (withAuth && token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}
