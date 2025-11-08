// lib/core/api/api_response.dart
class ApiResponse<T> {
  final String message;
  final String error;
  final T data;

  ApiResponse({
    required this.message,
    required this.error,
    required this.data,
  });
}

class ApiErrorResponse {
  final String message;
  final String error;
  final Map<String, dynamic>? data;

  ApiErrorResponse({
    required this.message,
    required this.error,
    this.data,
  });

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    return ApiErrorResponse(
      message: json['message'] ?? '',
      error: json['error'] ?? 'unknown_error',
      data: json['data'],
    );
  }
}