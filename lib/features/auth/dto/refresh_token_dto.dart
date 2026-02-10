import 'dart:convert';

/// Respuesta al realizar refresh token
/// Endpoint: POST /token/refresh/
class RefreshTokenResponse {
  final String accessToken;
  final String refreshToken;

  RefreshTokenResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      // Los nombres de campos vienen del API como 'access_token' y 'refresh_token'
      accessToken: json['data']['access_token'] as String,
      refreshToken: json['data']['refresh_token'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
  };
}
