// lib/features/auth/models/register_models.dart

// Request model (se mantiene igual)
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
  final RegisterUser user;

  RegisterResponseData({
    required this.success,
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory RegisterResponseData.fromJson(Map<String, dynamic> json) {
    return RegisterResponseData(
      success: json['success'] ?? false,
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      user: RegisterUser.fromJson(json['user']),
    );
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