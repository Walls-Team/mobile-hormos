import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WhoopPromoService {
  static const String _lastShownKey = 'whoop_promo_last_shown';
  static const String _sessionShownKey = 'whoop_promo_session_shown';
  
  bool _shownInCurrentSession = false;
  
  /// Verifica si debe mostrar el modal de promoción
  /// Lógica: Mostrar solo si NO tiene dispositivo conectado y una vez por sesión
  Future<bool> shouldShowPromo({required bool hasDevice}) async {
    debugPrint('🎁 WHOOP Promo: Verificando condiciones...');
    debugPrint('   ✓ Tiene dispositivo conectado: $hasDevice');
    
    // VALIDACIÓN: NO mostrar si ya tiene dispositivo conectado
    if (hasDevice) {
      debugPrint('⚠️ WHOOP Promo: Ya tiene dispositivo, no mostrar');
      return false;
    }
    
    // Si ya se mostró en esta sesión, no mostrar de nuevo
    if (_shownInCurrentSession) {
      debugPrint('🎁 WHOOP Promo: Ya se mostró en esta sesión');
      return false;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      
      // Obtener la última vez que se mostró
      final lastShownTimestamp = prefs.getInt(_lastShownKey);
      
      if (lastShownTimestamp == null) {
        // Primera vez, mostrar
        debugPrint('🎁 WHOOP Promo: Primera vez, mostrando modal');
        return true;
      }
      
      final lastShown = DateTime.fromMillisecondsSinceEpoch(lastShownTimestamp);
      final difference = now.difference(lastShown);
      
      // Mostrar si han pasado más de 4 horas desde la última vez
      // Esto evita que sea muy invasivo si el usuario cierra y abre la app muchas veces
      if (difference.inHours >= 4) {
        debugPrint('🎁 WHOOP Promo: Han pasado ${difference.inHours} horas, mostrando modal');
        return true;
      }
      
      debugPrint('🎁 WHOOP Promo: Solo han pasado ${difference.inMinutes} minutos, no mostrar');
      return false;
    } catch (e) {
      debugPrint('❌ Error verificando WHOOP promo: $e');
      return false;
    }
  }
  
  /// Marca que el modal fue mostrado
  Future<void> markAsShown() async {
    _shownInCurrentSession = true;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      await prefs.setInt(_lastShownKey, now.millisecondsSinceEpoch);
      debugPrint('✅ WHOOP Promo: Marcado como mostrado');
    } catch (e) {
      debugPrint('❌ Error marcando WHOOP promo: $e');
    }
  }
  
  /// Resetea el estado (útil para testing)
  Future<void> reset() async {
    _shownInCurrentSession = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastShownKey);
      debugPrint('✅ WHOOP Promo: Estado reseteado');
    } catch (e) {
      debugPrint('❌ Error reseteando WHOOP promo: $e');
    }
  }
  
  /// Para forzar que se muestre (útil para testing)
  void forceShow() {
    _shownInCurrentSession = false;
  }
}
