# 💬 Implementación de Chat con IA

## ✅ Lo que se implementó

### 1. **Vista de Chat Completa** (`lib/features/chat/pages/chat_screen.dart`)
- ✅ Interfaz estilo Messenger de Facebook
- ✅ Burbujas de chat diferenciadas (usuario vs bot)
- ✅ Indicador de escritura animado
- ✅ Campo de texto con botón de envío
- ✅ Auto-scroll a nuevos mensajes
- ✅ Timestamps en cada mensaje
- ✅ Avatar del bot en el AppBar
- ✅ Indicador de "En línea" / "Escribiendo..."

### 2. **Modelo de Datos** (`lib/features/chat/models/chat_message.dart`)
```dart
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isTyping;
}
```

### 3. **Widget de Burbuja** (`lib/features/chat/widgets/chat_bubble.dart`)
- Burbujas amarillas para mensajes del usuario
- Burbujas grises para mensajes del bot
- Animación de puntos para indicador de escritura
- Formato de hora automático

### 4. **Integración en el Menú**
- Botón "Asistente Virtual" agregado en Perfil
- Navegación directa a la pantalla de chat
- Diseño consistente con el resto de la app

## 🔌 Cómo Conectar tu API de Chatbot

### Ubicación del Código
Abre `lib/features/chat/pages/chat_screen.dart` y busca la función `_simulateResponse`:

```dart
void _simulateResponse(String userText) {
  // Aquí es donde conectas tu API
  
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

  // REEMPLAZA ESTO con tu llamada a la API:
  Future.delayed(const Duration(milliseconds: 1500), () {
    // ... código existente
  });
}
```

### Ejemplo de Integración con HTTP

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

void _simulateResponse(String userText) async {
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
    // Llamar a tu API
    final response = await http.post(
      Uri.parse('https://tu-api.com/chatbot'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': userText,
        'userId': 'user_id_aqui',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final botResponse = data['response'] ?? 'Lo siento, no entendí';

      setState(() {
        _messages.removeWhere((msg) => msg.id == 'typing');
        _isTyping = false;

        _messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: botResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });

      _scrollToBottom();
    }
  } catch (e) {
    setState(() {
      _messages.removeWhere((msg) => msg.id == 'typing');
      _isTyping = false;

      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: 'Error de conexión. Por favor, intenta de nuevo.',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }
}
```

### Ejemplo con OpenAI

```dart
Future<void> _callOpenAI(String userText) async {
  final apiKey = 'TU_API_KEY_AQUI';
  
  try {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': 'Eres un asistente de salud amigable.'},
          {'role': 'user', 'content': userText},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final botResponse = data['choices'][0]['message']['content'];
      
      // Agregar el mensaje del bot
      setState(() {
        _messages.removeWhere((msg) => msg.id == 'typing');
        _isTyping = false;

        _messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: botResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

## 🎨 Personalización

### Cambiar Colores de las Burbujas

En `chat_bubble.dart`:

```dart
// Color de burbujas del usuario (línea 29)
color: message.isUser
    ? const Color(0xFFEDE954)  // Cambia este color
    : const Color(0xFF2A2C3B),

// Color del texto (línea 50)
color: message.isUser ? Colors.black : Colors.white,
```

### Cambiar el Nombre del Bot

En `chat_screen.dart`:

```dart
// Línea 168
const Text(
  'Asistente Virtual',  // Cambia el nombre aquí
  style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ),
),
```

### Mensaje de Bienvenida

En `chat_screen.dart`, método `_addWelcomeMessage()`:

```dart
void _addWelcomeMessage() {
  setState(() {
    _messages.add(
      ChatMessage(
        id: '1',
        text: '¡Hola! 👋 Soy tu asistente virtual. ¿En qué puedo ayudarte hoy?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  });
}
```

## 📱 Características Implementadas

✅ **Burbujas de chat estilo Messenger**
- Usuario: burbujas amarillas a la derecha
- Bot: burbujas grises a la izquierda
- Bordes redondeados con esquina puntiaguda

✅ **Indicador de escritura**
- Animación de 3 puntos mientras el bot "escribe"
- Se muestra automáticamente antes de cada respuesta

✅ **Timestamps**
- Cada mensaje muestra la hora de envío
- Formato HH:MM

✅ **Auto-scroll**
- La vista se desplaza automáticamente al último mensaje
- Smooth scroll animation

✅ **Campo de entrada mejorado**
- Placeholder texto
- Botón de envío circular
- Presionar Enter envía el mensaje

✅ **Estado del bot**
- "En línea" cuando está esperando
- "Escribiendo..." cuando está procesando

## 🚀 Cómo Probar

1. **Ejecuta la app desde Xcode** (ya está abierto):
   - Selecciona el simulador iPhone 16
   - Presiona Cmd + R o el botón ▶️ Play

2. **Navega al chat**:
   - Ve a Perfil/Configuración
   - Toca el botón "Asistente Virtual" (amarillo con icono de chat)

3. **Prueba el chat**:
   - Escribe un mensaje
   - Presiona enviar
   - Verás el indicador de escritura
   - Recibirás una respuesta automática

## 📝 Notas Importantes

- El chat actualmente usa respuestas simuladas locales
- Para conectar tu API, modifica la función `_simulateResponse` como se indica arriba
- Los mensajes no se guardan cuando cierras la app (puedes agregar persistencia más tarde)
- El diseño es completamente responsive y funciona en todos los tamaños de pantalla

## 🔧 Próximos Pasos Sugeridos

1. **Conectar API real**: Reemplaza las respuestas simuladas
2. **Persistencia**: Guarda el historial de chat con SharedPreferences o base de datos
3. **Archivos/Imágenes**: Permite enviar y recibir archivos
4. **Push Notifications**: Notifica cuando lleguen mensajes del bot
5. **Historial**: Agrega un botón para limpiar el chat
6. **Configuración**: Permite al usuario cambiar la personalidad del bot

## ✅ Estado Actual

- ✅ Vista de chat implementada
- ✅ Burbujas estilo Messenger
- ✅ Indicador de escritura animado
- ✅ Botón en el menú de configuración
- ✅ Listo para conectar tu API

**¡El chat está 100% funcional y listo para que conectes tu API de chatbot!**
