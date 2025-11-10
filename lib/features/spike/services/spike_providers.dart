// lib/services/spike_api_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:genius_hormo/core/api/api_helpers.dart';
import 'package:genius_hormo/features/auth/dto/login_dto.dart';
import 'package:genius_hormo/features/spike/models/spike_auth.dart';
import 'package:genius_hormo/features/spike/models/spike_integration.dart';
import 'package:http/http.dart' as http;

class SpikeApiService {
  static const String _baseUrl = 'http://localhost:3000';
  final http.Client _client;

  SpikeApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<String> requestSpikeAccesToken({
    required String userId,
    required String token,
  }) async {
    final result = await executeRequest<HmacAuthResponse>(
      request: _client
          .post(
            Uri.parse('$_baseUrl/auth/hmac'),
            headers: _getHeaders(withAuth: true, token: token),
            body: json.encode({'userId': userId}),
          )
          .timeout(const Duration(seconds: 30)),
      fromJson: HmacAuthResponse.fromJson,
    );

    if (result.data != null && result.data?.accessToken != null) {
      return result.data!.accessToken;
    }

    throw Exception('error al obtener token auth/hmac');
  }

  Future<ProviderIntegrationInit> requestWhoopIntegration({
    required String userId,
    required String token,
  }) async {
    final spikeUri =
        'https://app-api.spikeapi.com/v3/providers/whoop/integration/init_url';

    try {
      final spikeAccessToken = await requestSpikeAccesToken(
        userId: userId,
        token: token,
      );

      final spikeRes = await http
          .get(
            Uri.parse(spikeUri),
            headers: {
              'Authorization': 'Bearer $spikeAccessToken',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      return ProviderIntegrationInit.fromJson(json.decode(spikeRes.body));

    } catch (e) {
      throw Exception('whoop integration failed ${e.toString()}');
    }
  }

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
