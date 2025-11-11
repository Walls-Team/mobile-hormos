import 'package:flutter/foundation.dart';

class VerifyAccountResponseData {
  final String message;
  final String? accessToken;
  final String? refreshToken;
  final bool success;

  VerifyAccountResponseData({
    required this.message,
    this.accessToken,
    this.refreshToken,
    this.success = true,
  });

  factory VerifyAccountResponseData.fromJson(Map<String, dynamic> json) {
    debugPrint('🔍 Parsing VerifyAccountResponseData from: $json');
    
    final result = VerifyAccountResponseData(
      message: json['message'] as String? ?? 'Email verificado exitosamente',
      accessToken: json['access_token'] as String? ?? json['accessToken'] as String?,
      refreshToken: json['refresh_token'] as String? ?? json['refreshToken'] as String?,
      success: json['success'] as bool? ?? true,
    );
    
    debugPrint('✅ Parsed VerifyAccountResponseData: message=${result.message}');
    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }

  @override
  String toString() {
    return 'VerifyAccountResponseData(message: $message, accessToken: $accessToken, refreshToken: $refreshToken)';
  }

  // Para comparación y copia
  VerifyAccountResponseData copyWith({
    String? message,
    String? accessToken,
    String? refreshToken,
  }) {
    return VerifyAccountResponseData(
      message: message ?? this.message,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is VerifyAccountResponseData &&
        other.message == message &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken;
  }

  @override
  int get hashCode =>
      message.hashCode ^ accessToken.hashCode ^ refreshToken.hashCode;
}