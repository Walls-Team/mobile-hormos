class PasswordResetResponseData {
  final String message;

  PasswordResetResponseData({
    required this.message,
  });

  factory PasswordResetResponseData.fromJson(Map<String, dynamic> json) {
    return PasswordResetResponseData(
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}