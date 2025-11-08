// lib/services/device_storage_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:genius_hormo/features/spike/models/spike_models.dart';

class DeviceStorageService {
  static const String _deviceStorageKey = 'user_device_cache';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // ========== OPERACIONES DE DISPOSITIVO ==========
  
  /// Guarda dispositivo en storage
  Future<void> saveDevice(Device device) async {
    try {
      await _secureStorage.write(
        key: _deviceStorageKey,
        value: json.encode(device.toJson()),
      );
      print('✅ Dispositivo guardado');
    } catch (e) {
      print('❌ Error guardando dispositivo: $e');
      rethrow;
    }
  }

  /// Obtiene dispositivo guardado desde storage
  Future<Device?> getSavedDevice() async {
    try {
      final String? deviceJson = await _secureStorage.read(key: _deviceStorageKey);
      
      if (deviceJson != null && deviceJson.isNotEmpty) {
        return Device.fromJson(json.decode(deviceJson));
      }
      
      return null;
    } catch (e) {
      print('❌ Error obteniendo dispositivo guardado: $e');
      return null;
    }
  }

  /// Verifica si hay dispositivo guardado
  Future<bool> hasSavedDevice() async {
    final device = await getSavedDevice();
    return device != null;
  }

  /// Verifica si hay dispositivo conectado
  Future<bool> hasConnectedDevice() async {
    final device = await getSavedDevice();
    return device != null && device.isConnected == true;
  }

  /// Elimina dispositivo del storage
  Future<void> clearSavedDevice() async {
    try {
      await _secureStorage.delete(key: _deviceStorageKey);
      print('✅ Dispositivo eliminado del storage');
    } catch (e) {
      print('❌ Error limpiando dispositivo: $e');
      rethrow;
    }
  }

  // ========== MÉTODOS DE DIAGNÓSTICO ==========
  
  /// Obtiene información del dispositivo almacenado
  Future<Map<String, dynamic>> getDeviceStorageInfo() async {
    final device = await getSavedDevice();
    
    return {
      'hasDevice': device != null,
      'deviceId': device?.id,
      'isConnected': device?.isConnected,
      'deviceProvider': device?.provider,
    };
  }
}