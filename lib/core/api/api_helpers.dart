// ignore_for_file: unused_catch_clause

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:genius_hormo/core/api/api_response.dart';
import 'package:http/http.dart' as http;

Future<ApiResponse<T>> executeRequest<T>({
  required Future<http.Response> request,
  required T Function(Map<String, dynamic>) fromJson,
}) async {
  try {
    final response = await request;
    return handleApiResponse(response, fromJson);
  } on SocketException catch (e) {
    return ApiResponse.error(message: 'Error de conexión: $e');
  } on TimeoutException catch (e) {
    return ApiResponse.error(message: 'Tiempo de espera agotado');
  } on FormatException catch (e) {
    return ApiResponse.error(message: 'Error en el formato de respuesta');
  } catch (e) {
    return ApiResponse.error(message: 'Error inesperado: $e');
  }
}

ApiResponse<T> handleApiResponse<T>(
  http.Response response,
  // T Function(dynamic) dataMapper,
  T Function(Map<String, dynamic>) dataMapper,
) {
  final Map<String, dynamic> responseData = json.decode(response.body);

  if (response.statusCode == 200 || response.statusCode == 201) {
    final String? error = responseData['error'];
    final bool hasError = error != null && error.isNotEmpty;

    if (!hasError) {
      return ApiResponse.success(
        message: responseData['message'] ?? 'Operación exitosa',
        data: dataMapper(responseData['data']),
      );
    } else {
      return ApiResponse.error(message: error);
    }
  } else {
    return ApiResponse.error(
      message:
          responseData['message'] ??
          responseData['error'] ??
          'Error en la operación - Código: ${response.statusCode}',
    );
  }
}
