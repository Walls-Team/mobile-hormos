import 'package:flutter/foundation.dart';

class RegisterRequest {
  final String username;
  final String email;
  final String password;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
    };
  }
}

// Response models CORREGIDOS según la estructura real
class RegisterResponseData {
  final bool success;
  final String accessToken;
  final String refreshToken;
  final RegisterUser? user;

  RegisterResponseData({
    required this.success,
    required this.accessToken,
    required this.refreshToken,
    this.user,
  });

  factory RegisterResponseData.fromJson(Map<String, dynamic> json) {
    debugPrint('🔍 Parsing RegisterResponseData from: $json');
    
    // Intentar obtener el usuario de diferentes ubicaciones
    RegisterUser? user;
    if (json['user'] != null) {
      user = RegisterUser.fromJson(json['user']);
    } else if (json['data'] != null && json['data'] is Map) {
      // Si viene en 'data', intentar parsearlo
      final dataMap = json['data'] as Map<String, dynamic>;
      if (dataMap['user'] != null) {
        user = RegisterUser.fromJson(dataMap['user']);
      } else if (dataMap['id'] != null) {
        // Si 'data' es directamente el usuario
        user = RegisterUser.fromJson(dataMap);
      }
    }
    
    final result = RegisterResponseData(
      success: json['success'] ?? false,
      accessToken: json['access_token'] ?? json['accessToken'] ?? '',
      refreshToken: json['refresh_token'] ?? json['refreshToken'] ?? '',
      user: user,
    );
    
    debugPrint('✅ Parsed RegisterResponseData: success=${result.success}');
    return result;
  }
}

class RegisterUser {
  final String id;
  final String profileId;
  final String username;
  final bool spikeConnect;

  RegisterUser({
    required this.id,
    required this.profileId,
    required this.username,
    required this.spikeConnect,
  });

  factory RegisterUser.fromJson(Map<String, dynamic> json) {
    return RegisterUser(
      id: json['id'] ?? '',
      profileId: json['profile_id'] ?? '',
      username: json['username'] ?? '',
      spikeConnect: json['spike_connect'] ?? false,
    );
  }
}