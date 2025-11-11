import 'package:flutter/foundation.dart';

class ResendOtpResponseData {
  final String message;
  final bool success;

  ResendOtpResponseData({
    required this.message,
    this.success = true,
  });

  factory ResendOtpResponseData.fromJson(Map<String, dynamic> json) {
    debugPrint('🔍 Parsing ResendOtpResponseData from: $json');
    
    final result = ResendOtpResponseData(
      message: json['message'] as String? ?? 'Código reenviado exitosamente',
      success: json['success'] as bool? ?? true,
    );
    
    debugPrint('✅ Parsed ResendOtpResponseData: message=${result.message}');
    return result;
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'success': success,
  };

  @override
  String toString() => 'ResendOtpResponseData(message: $message, success: $success)';
}