import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:genius_hormo/core/api/api_response.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

/// Servicio para comunicarse con el bot Noa Genius
class NoaBotService {
  final http.Client _client;
  final UserStorageService _userStorageService;
  static const String _baseUrl = 'https://agent.geniushpro.com';
  static const String _chatEndpoint = '/api/v1/chat';
  static const String _historyEndpoint = '/api/v1/history';

  NoaBotService({http.Client? client}) 
      : _client = client ?? http.Client(),
        _userStorageService = GetIt.instance<UserStorageService>();

  /// Enviar un mensaje al bot Noa Genius
  /// 
  /// [message] - El contenido del mensaje del usuario
  /// [userName] - Nombre del usuario para personalizar la respuesta (opcional)
  /// [type] - Tipo de mensaje: "text" o "file"
  /// [fileUrl] - URL pública del archivo si type es "file" (opcional)
  /// Obtiene el historial de chat del usuario
  /// Retorna una lista de mensajes del historial
  Future<ApiResponse<List<ChatHistoryMessage>>> getChatHistory() async {
    try {
      final url = '$_baseUrl$_historyEndpoint';
      
      // Obtener token JWT para autenticación
      final token = await _userStorageService.getJWTToken();
      
      if (token == null) {
        return ApiResponse.error(
          message: 'No hay token de autenticación disponible',
        );
      }
      
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔍 OBTENIENDO HISTORIAL DE CHAT');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📍 URL: $url');
      
      final response = await _client
          .get(
            Uri.parse(url),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 30));
          
      debugPrint('📥 Respuesta: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['messages'] ?? [];
        final List<ChatHistoryMessage> messages = data
            .map((item) => ChatHistoryMessage.fromJson(item))
            .toList();
        
        debugPrint('✅ Historial obtenido: ${messages.length} mensajes');
        
        return ApiResponse.success(
          data: messages,
          message: 'Historial obtenido correctamente',
        );
      } else {
        // Intentar parsear el error del servidor
        String errorMessage = 'Error al obtener el historial de chat';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['detail'] ?? errorMessage;
        } catch (e) {
          errorMessage = 'Error ${response.statusCode}: ${response.body}';
        }
        
        debugPrint('❌ Error: $errorMessage');
        return ApiResponse.error(message: errorMessage);
      }
    } catch (e, stackTrace) {
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ ERROR OBTENIENDO HISTORIAL DE CHAT');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔴 Error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      
      return ApiResponse.error(
        message: 'Error al obtener el historial de chat: $e',
      );
    }
  }

  Future<ApiResponse<NoaBotResponse>> sendMessage({
    required String message,
    String? userName,
    String type = 'text',
    String? fileUrl,
    String? threadId,
  }) async {
    try {
      final url = '$_baseUrl$_chatEndpoint';
      
      final Map<String, dynamic> body = {
        'message': message,
        'type': type,
      };
      
      // Añadir thread_id si está disponible para mantener la conversación
      if (threadId != null && threadId.isNotEmpty) {
        body['thread_id'] = threadId;
      }
      
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
      
      // Obtener token JWT para autenticación
      final token = await _userStorageService.getJWTToken();
      
      if (token == null) {
        return ApiResponse.error(
          message: 'No hay token de autenticación disponible',
        );
      }
      
      final response = await _client
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
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

/// Modelo para mensajes del historial de chat
class ChatHistoryMessage {
  final String id;
  final String content;
  final String role; // 'user' o 'assistant'
  final DateTime createdAt;

  ChatHistoryMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.createdAt,
  });

  factory ChatHistoryMessage.fromJson(Map<String, dynamic> json) {
    return ChatHistoryMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  bool get isUser => role == 'user';
}
