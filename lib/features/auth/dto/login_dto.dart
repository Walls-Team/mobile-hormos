import 'package:flutter/foundation.dart';

class LoginUser {
  final String id;
  final String profileId;
  final String username;
  final bool spikeConnect;

  LoginUser({
    required this.id,
    required this.profileId,
    required this.username,
    required this.spikeConnect,
  });

  factory LoginUser.fromJson(Map<String, dynamic> json) {
    return LoginUser(
      id: json['id'] as String? ?? '',
      profileId: json['profile_id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      spikeConnect: json['spike_connect'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'username': username,
      'spike_connect': spikeConnect,
    };
  }
}

class LoginResponse {
  final bool success;
  final String accessToken;
  final String refreshToken;
  final LoginUser user;

  LoginResponse({
    required this.success,
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    debugPrint('🔍 Parsing LoginResponse from: $json');
    
    // Intentar obtener el usuario de diferentes ubicaciones
    LoginUser user;
    if (json['user'] != null && json['user'] is Map) {
      user = LoginUser.fromJson(json['user'] as Map<String, dynamic>);
    } else if (json['data'] != null && json['data'] is Map) {
      final dataMap = json['data'] as Map<String, dynamic>;
      if (dataMap['user'] != null) {
        user = LoginUser.fromJson(dataMap['user'] as Map<String, dynamic>);
      } else {
        user = LoginUser.fromJson(dataMap);
      }
    } else {
      user = LoginUser.fromJson({});
    }
    
    final result = LoginResponse(
      success: json['success'] as bool? ?? true,
      accessToken: json['access_token'] as String? ?? json['accessToken'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? json['refreshToken'] as String? ?? '',
      user: user,
    );
    
    debugPrint('✅ Parsed LoginResponse: success=${result.success}');
    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user': user.toJson(),
    };
  }
}

class LoginRequest {
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}