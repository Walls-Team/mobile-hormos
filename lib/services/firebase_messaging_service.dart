import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:genius_hormo/services/local_notifications_service.dart';

/// Servicio para manejar notificaciones push de Firebase Cloud Messaging
class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  LocalNotificationsService? _localNotificationsService;
  
  String? _fcmToken;
  String? get fcmToken => _fcmToken;
  
  /// Establecer referencia al servicio de notificaciones locales
  void setLocalNotificationsService(LocalNotificationsService service) {
    _localNotificationsService = service;
  }

  /// Inicializar Firebase Messaging
  Future<void> initialize() async {
    debugPrint('🔔 Inicializando Firebase Messaging...');
    
    try {
      // Solicitar permisos para notificaciones
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('📱 Permiso de notificaciones: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ Usuario autorizó notificaciones');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('⚠️ Usuario autorizó notificaciones provisionales');
      } else {
        debugPrint('❌ Usuario denegó notificaciones');
        return;
      }

      // Obtener el token FCM
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('🎫 FCM Token: $_fcmToken');

      // Escuchar cambios en el token
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        debugPrint('🔄 FCM Token actualizado: $newToken');
        _fcmToken = newToken;
        // TODO: Enviar el nuevo token al backend
        _sendTokenToBackend(newToken);
      });

      // Configurar handlers de notificaciones
      _setupNotificationHandlers();

      debugPrint('✅ Firebase Messaging inicializado correctamente');
    } catch (e) {
      debugPrint('❌ Error inicializando Firebase Messaging: $e');
    }
  }

  /// Configurar handlers para diferentes estados de notificaciones
  void _setupNotificationHandlers() {
    // Notificación recibida cuando la app está en FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📨 Notificación recibida en foreground:');
      debugPrint('   Título: ${message.notification?.title}');
      debugPrint('   Cuerpo: ${message.notification?.body}');
      debugPrint('   Data: ${message.data}');
      
      // TODO: Mostrar notificación local o diálogo en la app
      _handleForegroundNotification(message);
    });

    // Notificación tocada cuando la app está en BACKGROUND
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📲 Notificación tocada (app en background):');
      debugPrint('   Data: ${message.data}');
      
      // TODO: Navegar a la pantalla correspondiente según el tipo de notificación
      _handleNotificationTap(message);
    });

    // Verificar si la app se abrió desde una notificación (TERMINATED state)
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('🚀 App abierta desde notificación (terminated):');
        debugPrint('   Data: ${message.data}');
        
        // TODO: Navegar a la pantalla correspondiente
        _handleNotificationTap(message);
      }
    });
  }

  /// Manejar notificación cuando la app está en foreground
  void _handleForegroundNotification(RemoteMessage message) {
    debugPrint('🔔 Procesando notificación en foreground...');
    
    // Guardar notificación localmente
    if (_localNotificationsService != null) {
      _localNotificationsService!.addNotification(
        title: message.notification?.title ?? 'Nueva notificación',
        body: message.notification?.body ?? '',
        type: message.data['type'],
        data: message.data,
      );
      debugPrint('✅ Notificación guardada localmente');
    }
  }

  /// Manejar cuando el usuario toca una notificación
  void _handleNotificationTap(RemoteMessage message) {
    // TODO: Implementar navegación según el tipo de notificación
    // Ejemplo: 
    // - Si es tipo "daily_reminder" -> ir a cuestionario
    // - Si es tipo "new_data" -> ir a dashboard
    // - Si es tipo "device_sync" -> ir a ajustes
    
    debugPrint('👆 Usuario tocó notificación');
    debugPrint('   Tipo: ${message.data['type']}');
    
    final notificationType = message.data['type'];
    switch (notificationType) {
      case 'daily_reminder':
        // Navegar al cuestionario
        break;
      case 'new_data':
        // Navegar al dashboard
        break;
      case 'device_sync':
        // Navegar a ajustes
        break;
      default:
        debugPrint('⚠️ Tipo de notificación desconocido: $notificationType');
    }
  }

  /// Enviar token al backend
  Future<void> _sendTokenToBackend(String token) async {
    try {
      debugPrint('📤 Enviando token al backend: $token');
      
      // TODO: Implementar llamada al API para guardar el token
      // final response = await apiService.saveDeviceToken(token: token);
      
      debugPrint('✅ Token enviado al backend correctamente');
    } catch (e) {
      debugPrint('❌ Error enviando token al backend: $e');
    }
  }

  /// Suscribirse a un topic para notificaciones grupales
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('✅ Suscrito al topic: $topic');
    } catch (e) {
      debugPrint('❌ Error suscribiendo a topic $topic: $e');
    }
  }

  /// Desuscribirse de un topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('✅ Desuscrito del topic: $topic');
    } catch (e) {
      debugPrint('❌ Error desuscribiendo de topic $topic: $e');
    }
  }
}

/// Handler global para notificaciones en background
/// Debe ser una función top-level (no dentro de una clase)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🔔 Notificación recibida en background:');
  debugPrint('   Título: ${message.notification?.title}');
  debugPrint('   Cuerpo: ${message.notification?.body}');
  debugPrint('   Data: ${message.data}');
  
  // TODO: Procesar notificación en background si es necesario
}
