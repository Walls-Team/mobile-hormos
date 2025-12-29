import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:genius_hormo/core/api/api_response.dart';
import 'package:http/http.dart' as http;

/// Servicio para comunicarse con el bot Noa Genius
class NoaBotService {
  final http.Client _client;
  static const String _baseUrl = 'http://agent.geniushpro.com';
  static const String _chatEndpoint = '/api/v1/chat';

  NoaBotService({http.Client? client}) : _client = client ?? http.Client();

  /// Enviar un mensaje al bot Noa Genius
  /// 
  /// [message] - El contenido del mensaje del usuario
  /// [userName] - Nombre del usuario para personalizar la respuesta (opcional)
  /// [type] - Tipo de mensaje: "text" o "file"
  /// [fileUrl] - URL pública del archivo si type es "file" (opcional)
  Future<ApiResponse<NoaBotResponse>> sendMessage({
    required String message,
    String? userName,
    String type = 'text',
    String? fileUrl,
  }) async {
    try {
      final url = '$_baseUrl$_chatEndpoint';
      
      final Map<String, dynamic> body = {
        'message': message,
        'type': type,
      };
      
      // Añadir nombre de usuario si está disponible
      if (userName != null && userName.isNotEmpty) {
        body['sub'] = userName;
      }
      
      // Añadir URL del archivo si está disponible
      if (fileUrl != null && fileUrl.isNotEmpty) {
        body['fileUrl'] = fileUrl;
      }
      
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🤖 ENVIANDO MENSAJE AL BOT NOA');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📍 URL: $url');
      debugPrint('💬 Mensaje: $message');
      debugPrint('👤 Usuario: ${userName ?? "Anónimo"}');
      debugPrint('📝 Tipo: $type');
      
      final response = await _client
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));
          
      debugPrint('📥 Respuesta: ${response.statusCode}');
      debugPrint('📄 Cuerpo: ${response.body}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final botResponse = NoaBotResponse.fromJson(data);
        
        return ApiResponse.success(
          data: botResponse,
          message: 'Respuesta recibida correctamente',
        );
      } else {
        // Intentar parsear el error del servidor
        String errorMessage = 'Error al comunicarse con el bot';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['detail'] ?? errorMessage;
        } catch (e) {
          errorMessage = 'Error ${response.statusCode}: ${response.body}';
        }
        
        return ApiResponse.error(message: errorMessage);
      }
    } catch (e, stackTrace) {
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ ERROR COMUNICÁNDOSE CON EL BOT');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔴 Error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      
      return ApiResponse.error(
        message: 'Error al comunicarse con el bot: $e',
      );
    }
  }
}

/// Modelo de respuesta del bot Noa Genius
class NoaBotResponse {
  final String message;
  final String type;
  final String? fileUrl;

  NoaBotResponse({
    required this.message,
    required this.type,
    this.fileUrl,
  });

  factory NoaBotResponse.fromJson(Map<String, dynamic> json) {
    return NoaBotResponse(
      message: json['message'] as String,
      type: json['type'] as String,
      fileUrl: json['fileUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'type': type,
      'fileUrl': fileUrl,
    };
  }
}
