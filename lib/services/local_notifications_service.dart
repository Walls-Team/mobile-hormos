import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Modelo de notificación local
class LocalNotification {
  final String id;
  final String title;
  final String body;
  final String? type;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  final bool isRead;

  LocalNotification({
    required this.id,
    required this.title,
    required this.body,
    this.type,
    this.data,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
      };

  factory LocalNotification.fromJson(Map<String, dynamic> json) =>
      LocalNotification(
        id: json['id'],
        title: json['title'],
        body: json['body'],
        type: json['type'],
        data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
        timestamp: DateTime.parse(json['timestamp']),
        isRead: json['isRead'] ?? false,
      );
}

/// Servicio para manejar notificaciones locales en la app
class LocalNotificationsService extends ChangeNotifier {
  static const String _storageKey = 'local_notifications';
  static const int _maxNotifications = 50; // Máximo de notificaciones guardadas

  List<LocalNotification> _notifications = [];
  
  List<LocalNotification> get notifications => _notifications;
  
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Inicializar y cargar notificaciones guardadas
  Future<void> initialize() async {
    debugPrint('📬 Inicializando servicio de notificaciones locales...');
    await _loadNotifications();
    debugPrint('✅ Notificaciones cargadas: ${_notifications.length}');
    debugPrint('📧 No leídas: $unreadCount');
  }

  /// Cargar notificaciones desde SharedPreferences
  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notificationsJson = prefs.getString(_storageKey);

      if (notificationsJson != null) {
        final List<dynamic> decoded = json.decode(notificationsJson);
        _notifications = decoded
            .map((item) => LocalNotification.fromJson(item))
            .toList();
        
        // Ordenar por fecha (más reciente primero)
        _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error cargando notificaciones: $e');
      _notifications = [];
    }
  }

  /// Guardar notificaciones en SharedPreferences
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(
        _notifications.map((n) => n.toJson()).toList(),
      );
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('❌ Error guardando notificaciones: $e');
    }
  }

  /// Agregar una nueva notificación
  Future<void> addNotification({
    required String title,
    required String body,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    final notification = LocalNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      data: data,
      timestamp: DateTime.now(),
      isRead: false,
    );

    _notifications.insert(0, notification);

    // Limitar el número de notificaciones
    if (_notifications.length > _maxNotifications) {
      _notifications = _notifications.sublist(0, _maxNotifications);
    }

    await _saveNotifications();
    notifyListeners();

    debugPrint('✅ Notificación agregada: $title');
    debugPrint('📊 Total: ${_notifications.length}, No leídas: $unreadCount');
  }

  /// Marcar una notificación como leída
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = LocalNotification(
        id: _notifications[index].id,
        title: _notifications[index].title,
        body: _notifications[index].body,
        type: _notifications[index].type,
        data: _notifications[index].data,
        timestamp: _notifications[index].timestamp,
        isRead: true,
      );

      await _saveNotifications();
      notifyListeners();

      debugPrint('✅ Notificación marcada como leída');
      debugPrint('📊 No leídas restantes: $unreadCount');
    }
  }

  /// Marcar todas como leídas
  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => LocalNotification(
          id: n.id,
          title: n.title,
          body: n.body,
          type: n.type,
          data: n.data,
          timestamp: n.timestamp,
          isRead: true,
        )).toList();

    await _saveNotifications();
    notifyListeners();

    debugPrint('✅ Todas las notificaciones marcadas como leídas');
  }

  /// Eliminar una notificación
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications();
    notifyListeners();

    debugPrint('🗑️ Notificación eliminada');
  }

  /// Eliminar todas las notificaciones
  Future<void> deleteAll() async {
    _notifications.clear();
    await _saveNotifications();
    notifyListeners();

    debugPrint('🗑️ Todas las notificaciones eliminadas');
  }

  /// Obtener notificaciones no leídas
  List<LocalNotification> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  /// Limpiar notificaciones antiguas (más de 30 días)
  Future<void> cleanOldNotifications() async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final oldCount = _notifications.length;
    
    _notifications.removeWhere((n) => n.timestamp.isBefore(thirtyDaysAgo));
    
    if (_notifications.length < oldCount) {
      await _saveNotifications();
      notifyListeners();
      
      debugPrint('🧹 Limpieza: ${oldCount - _notifications.length} notificaciones antiguas eliminadas');
    }
  }
}
