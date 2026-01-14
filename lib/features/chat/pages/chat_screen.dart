import 'package:flutter/material.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/features/chat/services/noa_bot_service.dart';
import 'package:get_it/get_it.dart';
import '../models/chat_message.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/loading_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isLoadingHistory = true;
  final NoaBotService _noaBotService = NoaBotService();
  String? _userName;
  String? _threadId;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadChatHistory();
  }
  
  Future<void> _loadUserName() async {
    try {
      final userStorageService = GetIt.instance<UserStorageService>();
      final userProfile = await userStorageService.getCurrentUser();
      if (userProfile != null && mounted) {
        setState(() {
          _userName = userProfile.username;
        });
      }
    } catch (e) {
      debugPrint('Error cargando nombre de usuario: $e');
    }
  }

  void _addWelcomeMessage() {
    // Solo añadir mensaje de bienvenida si no hay mensajes en el historial
    if (_messages.isEmpty) {
      setState(() {
        _messages.add(
          ChatMessage(
            id: '1',
            text: '¡Hola! 👋 Soy Noa, tu asistente de Genius Hormo. ¿En qué puedo ayudarte hoy?',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    }
    _scrollToBottom();
  }
  
  Future<void> _loadChatHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });
    
    try {
      final response = await _noaBotService.getChatHistory();
      
      if (!mounted) return;
      
      if (response.success && response.data != null) {
        final historyMessages = response.data!;
        
        // Si hay mensajes en el historial, convertirlos al formato del chat
        if (historyMessages.isNotEmpty) {
          setState(() {
            _messages.clear(); // Limpiar mensajes existentes
            
            // Convertir mensajes del historial al formato del chat
            for (final msg in historyMessages) {
              _messages.add(
                ChatMessage(
                  id: msg.id,
                  text: msg.content,
                  isUser: msg.isUser,
                  timestamp: msg.createdAt,
                ),
              );
            }
            
            // Si hay un thread_id en el primer mensaje, guardarlo
            if (historyMessages.isNotEmpty) {
              _threadId = historyMessages.first.id;
            }
          });
        } else {
          // Si no hay historial, mostrar mensaje de bienvenida
          _addWelcomeMessage();
        }
      } else {
        // Si hay error al cargar el historial, mostrar mensaje de bienvenida
        _addWelcomeMessage();
        debugPrint('Error cargando historial: ${response.message}');
      }
    } catch (e) {
      if (!mounted) return;
      _addWelcomeMessage();
      debugPrint('Error en _loadChatHistory: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _messageController.clear();
    });

    _scrollToBottom();
    _simulateResponse(text);
  }

  void _simulateResponse(String userText) async {
    // Mostrar indicador de escritura
    setState(() {
      _isTyping = true;
      _messages.add(
        ChatMessage(
          id: 'typing',
          text: '',
          isUser: false,
          timestamp: DateTime.now(),
          isTyping: true,
        ),
      );
    });

    _scrollToBottom();

    try {
      // Llamar al servicio del bot Noa Genius
      final response = await _noaBotService.sendMessage(
        message: userText,
        userName: _userName,
        type: 'text',
        threadId: _threadId, // Usar threadId para mantener el contexto de la conversación
      );
      
      // Si es un nuevo thread, guardar el ID
      if (response.success && response.data != null && _threadId == null) {
        // En la primera respuesta, guardar threadId para futuras conversaciones
        setState(() {
          // El threadId se genera en el servidor, podríamos extraerlo de la respuesta si se incluye
          _threadId = DateTime.now().millisecondsSinceEpoch.toString();
        });
      }

      if (!mounted) return;

      setState(() {
        _messages.removeWhere((msg) => msg.id == 'typing');
        _isTyping = false;

        if (response.success && response.data != null) {
          // Respuesta exitosa del bot
          _messages.add(
            ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text: response.data!.message,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        } else {
          // Error al obtener respuesta
          _messages.add(
            ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text: 'Lo siento, tuve un problema al procesar tu mensaje. ¿Podrías intentarlo de nuevo?',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        }
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint('Error al obtener respuesta del bot: $e');
      
      if (!mounted) return;
      
      setState(() {
        _messages.removeWhere((msg) => msg.id == 'typing');
        _isTyping = false;
        
        _messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: 'Lo siento, hubo un error al conectarme con el servidor. Por favor, intenta de nuevo.',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      
      _scrollToBottom();
    }
  }


  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1D23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1D23),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE954),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent,
                color: Colors.black,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Noa - Genius Hormo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _isTyping ? 'Escribiendo...' : 'En línea',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isTyping
                        ? const Color(0xFFEDE954)
                        : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoadingHistory 
              ? const LoadingIndicator(message: 'Cargando conversación...') 
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return ChatBubble(message: _messages[index]);
                  },
                ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2C3B),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1D23),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Escribe un mensaje...',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEDE954),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.black,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
