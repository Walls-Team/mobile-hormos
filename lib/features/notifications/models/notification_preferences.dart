/// Modelo que representa las preferencias de notificaciones del usuario
class NotificationPreferences {
  /// Recibir notificaciones diarias de recordatorio
  final bool dailyReminders;
  
  /// Recibir notificaciones de nuevos datos analizados
  final bool newDataAvailable;
  
  /// Recibir notificaciones de consejos y recomendaciones
  final bool tipsAndRecommendations;
  
  /// Recibir notificaciones de actualizaciones de la app
  final bool appUpdates;
  
  /// Recibir notificaciones sobre logros y metas
  final bool achievementsAndGoals;
  
  /// Permite vibración en notificaciones
  final bool enableVibration;
  
  /// Permite sonido en notificaciones
  final bool enableSound;
  
  /// Constructor
  NotificationPreferences({
    this.dailyReminders = true,
    this.newDataAvailable = true,
    this.tipsAndRecommendations = true,
    this.appUpdates = true,
    this.achievementsAndGoals = true,
    this.enableVibration = true,
    this.enableSound = true,
  });
  
  /// Constructor desde un mapa de datos (JSON)
  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      dailyReminders: json['daily_reminders'] ?? true,
      newDataAvailable: json['new_data_available'] ?? true,
      tipsAndRecommendations: json['tips_and_recommendations'] ?? true,
      appUpdates: json['app_updates'] ?? true,
      achievementsAndGoals: json['achievements_and_goals'] ?? true,
      enableVibration: json['enable_vibration'] ?? true,
      enableSound: json['enable_sound'] ?? true,
    );
  }
  
  /// Convertir a un mapa de datos (JSON)
  Map<String, dynamic> toJson() {
    return {
      'daily_reminders': dailyReminders,
      'new_data_available': newDataAvailable,
      'tips_and_recommendations': tipsAndRecommendations,
      'app_updates': appUpdates,
      'achievements_and_goals': achievementsAndGoals,
      'enable_vibration': enableVibration,
      'enable_sound': enableSound,
    };
  }
  
  /// Crear una copia con cambios específicos
  NotificationPreferences copyWith({
    bool? dailyReminders,
    bool? newDataAvailable,
    bool? tipsAndRecommendations,
    bool? appUpdates,
    bool? achievementsAndGoals,
    bool? enableVibration,
    bool? enableSound,
  }) {
    return NotificationPreferences(
      dailyReminders: dailyReminders ?? this.dailyReminders,
      newDataAvailable: newDataAvailable ?? this.newDataAvailable,
      tipsAndRecommendations: tipsAndRecommendations ?? this.tipsAndRecommendations,
      appUpdates: appUpdates ?? this.appUpdates,
      achievementsAndGoals: achievementsAndGoals ?? this.achievementsAndGoals,
      enableVibration: enableVibration ?? this.enableVibration,
      enableSound: enableSound ?? this.enableSound,
    );
  }
}
