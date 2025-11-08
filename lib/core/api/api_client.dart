// // lib/core/api/api_client.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:genius_hormo/core/api/api_response.dart';

// class ApiClient {
//   final String baseUrl;
//   final Map<String, String> defaultHeaders;

//   ApiClient({
//     required this.baseUrl,
//     this.defaultHeaders = const {
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//     },
//   });

//   Future<ApiResponse<T>> post<T>(
//     String endpoint, {
//     Map<String, dynamic>? data,
//     Map<String, String>? headers,
//     required T Function(Map<String, dynamic>) fromJson,
//   }) async {
//     try {
//       final url = Uri.parse('$baseUrl$endpoint');
//       final mergedHeaders = {...defaultHeaders, ...?headers};
      
//       final response = await http.post(
//         url,
//         headers: mergedHeaders,
//         body: data != null ? jsonEncode(data) : null,
//       );

//       final responseData = jsonDecode(response.body);

//       // Verificar si es una respuesta de error
//       if (response.statusCode >= 400) {
//         final errorResponse = ApiErrorResponse.fromJson(responseData);
//         throw ApiException(
//           message: errorResponse.message,
//           errorCode: errorResponse.error,
//           statusCode: response.statusCode,
//         );
//       }

//       // Para respuestas exitosas, usar el fromJson proporcionado
//       final T typedData = fromJson(responseData['data']);

//       return ApiResponse<T>(
//         message: responseData['message'] ?? '',
//         error: responseData['error'] ?? '',
//         data: typedData,
//       );
//     } catch (e) {
//       if (e is ApiException) rethrow;
//       throw ApiException(message:'Error de conexión: $e');
//     }
//   }

//   // También podemos agregar un método para GET
//   Future<ApiResponse<T>> get<T>(
//     String endpoint, {
//     Map<String, String>? headers,
//     required T Function(Map<String, dynamic>) fromJson,
//   }) async {
//     try {
//       final url = Uri.parse('$baseUrl$endpoint');
//       final mergedHeaders = {...defaultHeaders, ...?headers};
      
//       final response = await http.get(url, headers: mergedHeaders);
//       final responseData = jsonDecode(response.body);

//       if (response.statusCode >= 400) {
//         final errorResponse = ApiErrorResponse.fromJson(responseData);
//         throw ApiException(
//           message: errorResponse.message,
//           errorCode: errorResponse.error,
//           statusCode: response.statusCode,
//         );
//       }

//       final T typedData = fromJson(responseData['data']);

//       return ApiResponse<T>(
//         message: responseData['message'] ?? '',
//         error: responseData['error'] ?? '',
//         data: typedData,
//       );
//     } catch (e) {
//       if (e is ApiException) rethrow;
//       throw ApiException(message:'Error de conexión: $e');
//     }
//   }
// }

// class ApiException implements Exception {
//   final String message;
//   final String? errorCode;
//   final int? statusCode;

//   ApiException({
//     required this.message,
//     this.errorCode,
//     this.statusCode,
//   });

//   @override
//   String toString() => 'ApiException: $message${errorCode != null ? ' ($errorCode)' : ''}';
// }

// lib/core/api/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:genius_hormo/core/api/api_response.dart';

class ApiClient {
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  ApiClient({
    required this.baseUrl,
    this.defaultHeaders = const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  });

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final mergedHeaders = {...defaultHeaders, ...?headers};
      
      final response = await http.post(
        url,
        headers: mergedHeaders,
        body: data != null ? jsonEncode(data) : null,
      );

      final responseData = jsonDecode(response.body);
      print('🔍 Respuesta completa del servidor: $responseData');

      // Verificar si es una respuesta de error
      if (response.statusCode >= 400) {
        final errorResponse = ApiErrorResponse.fromJson(responseData);
        throw ApiException(
          message: errorResponse.message,
          errorCode: errorResponse.error,
          statusCode: response.statusCode,
        );
      }

      // ✅ CORRECCIÓN: Pasar responseData['data'] al fromJson
      final T typedData = fromJson(responseData['data']);

      return ApiResponse<T>(
        message: responseData['message'] ?? '',
        error: responseData['error'] ?? '',
        data: typedData,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message:'Error de conexión: $e');
    }
  }
}

class ApiException implements Exception {
  final String message;
  final String? errorCode;
  final int? statusCode;

  ApiException({
    required this.message,
    this.errorCode,
    this.statusCode,
  });

  @override
  String toString() => 'ApiException: $message${errorCode != null ? ' ($errorCode)' : ''}';
}