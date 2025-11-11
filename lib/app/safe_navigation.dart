import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Service to safely handle navigation, preventing crashes during hot restart
class SafeNavigation {
  static bool _isNavigationLocked = false;
  static DateTime? _lastNavigationTime;
  
  /// Lock navigation temporarily (used during hot restart)
  static void lockNavigation() {
    _isNavigationLocked = true;
    debugPrint('🔒 Navigation locked');
    
    // Auto-unlock after 500ms
    Future.delayed(const Duration(milliseconds: 500), () {
      _isNavigationLocked = false;
      debugPrint('🔓 Navigation unlocked');
    });
  }
  
  /// Check if we can navigate safely
  static bool canNavigate() {
    if (_isNavigationLocked) {
      debugPrint('⚠️ Navigation blocked - system is locked');
      return false;
    }
    
    // Prevent rapid navigation (minimum 50ms between navigations)
    if (_lastNavigationTime != null) {
      final timeSinceLastNav = DateTime.now().difference(_lastNavigationTime!);
      if (timeSinceLastNav.inMilliseconds < 50) {
        debugPrint('⚠️ Navigation blocked - too rapid');
        return false;
      }
    }
    
    return true;
  }
  
  /// Safe version of context.go()
  static void go(BuildContext context, String location) {
    if (!canNavigate()) return;
    
    _lastNavigationTime = DateTime.now();
    
    try {
      context.go(location);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Navigation error caught: $e');
      }
    }
  }
  
  /// Safe version of context.goNamed()
  static void goNamed(BuildContext context, String name, {Object? extra}) {
    if (!canNavigate()) return;
    
    _lastNavigationTime = DateTime.now();
    
    try {
      context.goNamed(name, extra: extra);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Navigation error caught: $e');
      }
    }
  }
}
