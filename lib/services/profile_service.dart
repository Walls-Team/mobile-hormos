import 'package:flutter/foundation.dart';
import 'package:genius_hormo/core/api/api_helpers.dart';
import 'package:genius_hormo/core/api/api_response.dart';
import 'package:genius_hormo/core/config/app_config.dart';
import 'package:http/http.dart' as http;

class AvatarsResponseData {
  final List<String> avatars;

  AvatarsResponseData({required this.avatars});

  factory AvatarsResponseData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final avatarsList = (data['avatars'] as List<dynamic>)
        .map((e) => e.toString())
        .toList();
    
    return AvatarsResponseData(avatars: avatarsList);
  }
}

class ProfileService {
  final http.Client _client;

  ProfileService({http.Client? client}) : _client = client ?? http.Client();

  /// Obtiene la lista de avatares disponibles
  Future<ApiResponse<AvatarsResponseData>> getAvatars({
    required String token,
  }) async {
    final url = AppConfig.getApiUrl('avatars/');
    
    debugPrint('🎨 GET AVATARS REQUEST');
    debugPrint('📍 URL: $url');

    return executeRequest<AvatarsResponseData>(
      request: _client
          .get(
            Uri.parse(url),
            headers: AppConfig.getCommonHeaders(withAuth: true, token: token),
          )
          .timeout(AppConfig.defaultTimeout),
      fromJson: AvatarsResponseData.fromJson,
    );
  }
}
