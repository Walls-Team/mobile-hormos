class VerifyAccountResponseData {
  final String message;
  final String? accessToken;
  final String? refreshToken;

  VerifyAccountResponseData({
    required this.message,
    this.accessToken,
    this.refreshToken,
  });

  factory VerifyAccountResponseData.fromJson(Map<String, dynamic> json) {
    return VerifyAccountResponseData(
      message: json['message'] as String,
      accessToken: json['access_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
    );
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