// ignore_for_file: unused_catch_clause

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
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
    debugPrint('❌ SOCKET ERROR: $e');
    return ApiResponse.error(message: 'Error de conexión: $e');
  } on TimeoutException catch (e) {
    debugPrint('❌ TIMEOUT ERROR: $e');
    return ApiResponse.error(message: 'Tiempo de espera agotado');
  } on FormatException catch (e) {
    debugPrint('❌ FORMAT ERROR: $e');
    return ApiResponse.error(message: 'Error en el formato de respuesta: $e');
  } catch (e) {
    debugPrint('❌ UNEXPECTED ERROR: $e');
    return ApiResponse.error(message: 'Error inesperado: $e');
  }
}

ApiResponse<T> handleApiResponse<T>(
  http.Response response,
  // T Function(dynamic) dataMapper,
  T Function(Map<String, dynamic>) dataMapper,
) {
  debugPrint('📥 RESPONSE STATUS: ${response.statusCode}');
  debugPrint('📥 RESPONSE BODY: ${response.body}');
  
  // Manejar redirecciones
  if (response.statusCode == 301 || response.statusCode == 302 || response.statusCode == 307 || response.statusCode == 308) {
    debugPrint('⚠️ REDIRECT ${response.statusCode}: ${response.headers['location']}');
    return ApiResponse.error(message: 'Redirección detectada. Por favor, verifica la URL del endpoint.');
  }
  
  try {
    // Si la respuesta está vacía, retornar error
    if (response.body.isEmpty) {
      debugPrint('⚠️ RESPUESTA VACÍA');
      return ApiResponse.error(message: 'Respuesta vacía del servidor');
    }

    // Verificar si la respuesta es HTML (error 404/500)
    if (response.body.trim().startsWith('<') || response.body.trim().startsWith('<!')) {
      debugPrint('💥 RESPUESTA HTML DETECTADA (NO JSON)');
      debugPrint('📄 Primeras 200 chars: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      return ApiResponse.error(
        message: 'El servidor retornó HTML en lugar de JSON. Verifica que el endpoint sea correcto. Status: ${response.statusCode}'
      );
    }

    final Map<String, dynamic> responseData = json.decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final String? error = responseData['error'];
      final bool hasError = error != null && error.isNotEmpty;

      if (!hasError) {
        debugPrint('✅ SUCCESS: ${responseData['message']}');
        try {
          // Intentar parsear los datos
          // Primero intenta con 'data', luego con la respuesta completa
          final dataToMap = responseData['data'] ?? responseData;
          debugPrint('📦 Data a mapear: $dataToMap');
          
          final data = dataMapper(dataToMap);
          return ApiResponse.success(
            message: responseData['message'] ?? 'Operación exitosa',
            data: data,
          );
        } catch (e) {
          debugPrint('⚠️ ERROR PARSING DATA: $e');
          debugPrint('📦 Intentando parsear respuesta completa...');
          try {
            // Si falla, intentar con la respuesta completa
            final data = dataMapper(responseData);
            return ApiResponse.success(
              message: responseData['message'] ?? 'Operación exitosa',
              data: data,
            );
          } catch (e2) {
            debugPrint('❌ ERROR EN SEGUNDO INTENTO: $e2');
            return ApiResponse.error(message: 'Error al parsear datos: $e2');
          }
        }
      } else {
        debugPrint('❌ ERROR: $error');
        return ApiResponse.error(message: error);
      }
    } else {
      debugPrint('❌ HTTP ERROR ${response.statusCode}');
      return ApiResponse.error(
        message:
            responseData['message'] ??
            responseData['error'] ??
            'Error en la operación - Código: ${response.statusCode}',
      );
    }
  } catch (e) {
    debugPrint('💥 ERROR DECODING JSON: $e');
    return ApiResponse.error(
      message: 'Error al procesar la respuesta: $e',
    );
  }
}
