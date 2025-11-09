class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? error;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory ApiResponse.success({required String message, required T data}) {
    return ApiResponse(success: true, message: message, data: data);
  }

  factory ApiResponse.error({required String message, String? error}) {
    return ApiResponse(
      success: false,
      message: message,
      error: error ?? message,
    );
  }
}