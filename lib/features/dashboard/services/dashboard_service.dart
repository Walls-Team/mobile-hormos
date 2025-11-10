import 'dart:convert';

import 'package:genius_hormo/core/api/api_helpers.dart';
import 'package:genius_hormo/core/api/api_response.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/features/dashboard/dto/basic_metrics/sleep_data_dto.dart';
import 'package:genius_hormo/features/dashboard/dto/profile_dto.dart';
import 'package:genius_hormo/features/dashboard/dto/update_profile_dto.dart';
import 'package:http/http.dart' as http;

class DashBoardService {
  static const String _baseUrl = 'http://localhost:3000';
  final UserStorageService _storageService;
  final http.Client _client;

  DashBoardService({UserStorageService? storageService, http.Client? client})
    : _storageService = storageService ?? UserStorageService(),
      _client = client ?? http.Client();

  Future<ApiResponse<UserProfileData>> getMyProfile(token) async {
    return executeRequest<UserProfileData>(
      request: _client
          .get(
            Uri.parse('$_baseUrl/v1/api/me'),
            headers: _getHeaders(withAuth: true, token: token),
          )
          .timeout(const Duration(seconds: 30)),
      fromJson: UserProfileData.fromJson,
    );
  }

  Future<ApiResponse<UpdateProfileResponseData>> updateProfile(token) async {
    return executeRequest<UpdateProfileResponseData>(
      request: _client
          .get(
            Uri.parse('$_baseUrl/v1/api/me/update'),
            headers: _getHeaders(withAuth: true, token: token),
          )
          .timeout(const Duration(seconds: 30)),
      fromJson: UpdateProfileResponseData.fromJson,
    );
  }

  // Future<ApiResponse<SleepData>> getBasicMetrics(token) async {
  //   await Future.delayed(const Duration(seconds: 3));

  //   final result = await executeRequest<SleepData>(
  //     request: _client
  //         .get(
  //           Uri.parse('$_baseUrl/v1/api/home/basic-metrics'),
  //           headers: _getHeaders(withAuth: true, token: token),
  //         )
  //         .timeout(const Duration(seconds: 30)),
  //     fromJson: SleepData.fromJson,
  //   );

  //   print(result.success);
  //   print(result.data);
  //   print(result.message);
  //   print(result.error);

  //   return result;
  // }

  Future<SleepData> getBasicMetrics(String token) async {
  await Future.delayed(const Duration(seconds: 3));

  final result = await executeRequest<SleepData>(
    request: _client
        .get(
          Uri.parse('$_baseUrl/v1/api/home/basic-metrics'),
          headers: _getHeaders(withAuth: true, token: token),
        )
        .timeout(const Duration(seconds: 30)),
    fromJson: SleepData.fromJson,
  );

  // ✅ MODIFICACIÓN CLAVE: Manejar el error aquí y lanzar excepción
  if (!result.success || result.data == null) {
    throw Exception(result.message ?? 'Error al cargar las métricas');
  }

  // ✅ Ahora retornamos directamente SleepData, no ApiResponse<SleepData>
  return result.data!;
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
