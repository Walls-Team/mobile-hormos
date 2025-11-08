// // // services/spike_service.dart
// // import 'dart:convert';
// // import 'package:http/http.dart' as http;
// // import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// // class SpikeService {
// //   static const String _baseUrl = 'http://localhost:3000'; // Misma URL base
// //   final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

// //   // Método para obtener los dispositivos del usuario
// //   Future<Map<String, dynamic>> myDevice() async {
// //     try {
// //       // Obtener el token JWT almacenado
// //       final String? token = await _secureStorage.read(key: 'jwt_token');
      
// //       if (token == null || token.isEmpty) {
// //         return {
// //           'success': false,
// //           'error': 'No hay token de autenticación disponible',
// //         };
// //       }

// //       print(Uri.parse('$_baseUrl/spike/my-device'));

// //       final response = await http.get(
// //         Uri.parse('$_baseUrl/spike/my-device'),
// //         headers: {
// //           'Content-Type': 'application/json',
// //           'Accept': 'application/json',
// //           'Authorization': 'Bearer $token', // Incluir el token en el header
// //         },
// //       );

// //       print('My Device Response status: ${response.statusCode}');
// //       print('My Device Response body: ${response.body}');

// //       if (response.statusCode == 200) {
// //         final Map<String, dynamic> responseData = json.decode(response.body);
        
// //         // Verificar si la respuesta es exitosa
// //         if (responseData['success'] == true) {
// //           return {
// //             'success': true,
// //             'data': responseData['data'] ?? responseData,
// //             'message': responseData['message'] ?? 'Dispositivos obtenidos exitosamente',
// //           };
// //         } else {
// //           return {
// //             'success': false,
// //             'error': responseData['message'] ?? 'Error al obtener los dispositivos',
// //           };
// //         }
// //       } else if (response.statusCode == 401) {
// //         // Token inválido o expirado
// //         return {
// //           'success': false,
// //           'error': 'Token de autenticación inválido o expirado',
// //           'unauthorized': true,
// //         };
// //       } else {
// //         final errorData = json.decode(response.body);
// //         return {
// //           'success': false,
// //           'error': errorData['message'] ?? 'Error al obtener los dispositivos',
// //           'statusCode': response.statusCode,
// //         };
// //       }
// //     } catch (e) {
// //       print('Error en myDevice: $e');
// //       return {
// //         'success': false,
// //         'error': 'Error de conexión: $e',
// //       };
// //     }
// //   }

// //   // Método auxiliar para verificar si hay un token disponible
// //   Future<bool> hasValidToken() async {
// //     try {
// //       final String? token = await _secureStorage.read(key: 'jwt_token');
// //       return token != null && token.isNotEmpty;
// //     } catch (e) {
// //       return false;
// //     }
// //   }

// //   // Método para obtener el token (útil para debugging)
// //   Future<String?> getToken() async {
// //     return await _secureStorage.read(key: 'jwt_token');
// //   }
// // }


// // services/spike_service.dart
// import 'dart:convert';
// import 'package:genius_hormo/features/spike/models/spike_models.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';


// class SpikeService {
//   static const String _baseUrl = 'http://localhost:3000';
//   final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

//   // OBTENER DISPOSITIVOS DEL USUARIO
//   Future<DevicesResponse> getMyDevices() async {
//     try {
//       final String? token = await _secureStorage.read(key: 'jwt_token');
      
//       if (token == null || token.isEmpty) {
//         return DevicesResponse.error(
//           message: 'No hay token de autenticación disponible',
//           unauthorized: true,
//         );
//       }

//       print('Request URL: $_baseUrl/spike/my-device');

//       final response = await http.get(
//         Uri.parse('$_baseUrl/spike/my-device'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       print('My Devices Response status: ${response.statusCode}');
//       print('My Devices Response body: ${response.body}');

//       // Verificar si la respuesta es HTML (error 404)
//       if (response.body.trim().startsWith('<!DOCTYPE html>') || 
//           response.body.trim().startsWith('<html>')) {
//         return DevicesResponse.error(
//           message: 'Endpoint no encontrado. Verifica la configuración del servidor.',
//           statusCode: 404,
//         );
//       }

//       final Map<String, dynamic> responseData = json.decode(response.body);

//       switch (response.statusCode) {
//         case 200:
//           final String? error = responseData['error'];
//           final bool hasError = error != null && error.isNotEmpty;

//           if (!hasError) {
//             // Procesar datos del dispositivo
//             final List<Device> devices = _processDeviceData(responseData);
            
//             return DevicesResponse.success(
//               message: responseData['message'] ?? 'Dispositivos obtenidos exitosamente',
//               devices: devices,
//             );
//           } else {
//             return DevicesResponse.error(
//               message: error ?? 'Error al obtener los dispositivos',
//             );
//           }

//         case 401:
//           return DevicesResponse.error(
//             message: 'Token de autenticación inválido o expirado',
//             unauthorized: true,
//             statusCode: 401,
//           );

//         case 404:
//           return DevicesResponse.error(
//             message: responseData['message'] ?? 'No se encontraron dispositivos',
//             statusCode: 404,
//           );

//         default:
//           return DevicesResponse.error(
//             message: responseData['message'] ?? 
//                     responseData['error'] ??
//                     'Error al obtener los dispositivos - Código: ${response.statusCode}',
//             statusCode: response.statusCode,
//           );
//       }
//     } catch (e) {
//       print('Error en getMyDevices: $e');
//       return DevicesResponse.error(
//         message: 'Error de conexión: $e',
//       );
//     }
//   }

//   // MÉTODO DE COMPATIBILIDAD (si necesitas mantener el nombre original)
//   Future<DevicesResponse> myDevice() async {
//     return await getMyDevices();
//   }

//   // VERIFICAR SI HAY DISPOSITIVOS CONECTADOS
//   Future<bool> hasConnectedDevices() async {
//     final DevicesResponse response = await getMyDevices();
//     return response.success && response.hasDevices;
//   }

//   // OBTENER DISPOSITIVO ACTIVO
//   Future<Device?> getActiveDevice() async {
//     final DevicesResponse response = await getMyDevices();
//     return response.activeDevice;
//   }

//   // MÉTODOS AUXILIARES
//   List<Device> _processDeviceData(Map<String, dynamic> responseData) {
//     final List<Device> devices = [];
    
//     // Caso 1: Datos en responseData['data']
//     if (responseData['data'] != null) {
//       if (responseData['data'] is Map) {
//         // Si es un solo dispositivo como objeto
//         devices.add(Device.fromJson(responseData['data']));
//       } else if (responseData['data'] is List) {
//         // Si es una lista de dispositivos
//         for (final deviceData in responseData['data']) {
//           devices.add(Device.fromJson(deviceData));
//         }
//       }
//     } 
//     // Caso 2: Datos directamente en la respuesta
//     else if (responseData['id'] != null) {
//       devices.add(Device.fromJson(responseData));
//     }
    
//     return devices;
//   }

//   // VERIFICAR SI HAY TOKEN VÁLIDO
//   Future<bool> hasValidToken() async {
//     try {
//       final String? token = await _secureStorage.read(key: 'jwt_token');
//       return token != null && token.isNotEmpty;
//     } catch (e) {
//       return false;
//     }
//   }

//   // OBTENER TOKEN (PARA DEBUGGING)
//   Future<String?> getToken() async {
//     return await _secureStorage.read(key: 'jwt_token');
//   }


// }


// services/spike_service.dart
import 'dart:convert';
import 'package:genius_hormo/features/spike/models/spike_models.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SpikeService {
  static const String _baseUrl = 'http://localhost:3000';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  static const String _deviceStorageKey = 'user_device_cache';

  // OBTENER DISPOSITIVO DEL USUARIO
  Future<DevicesResponse> getMyDevices() async {
    try {
      final String? token = await _secureStorage.read(key: 'jwt_token');
      
      if (token == null || token.isEmpty) {
        return DevicesResponse.error(
          message: 'No hay token de autenticación disponible',
          unauthorized: true,
        );
      }

      print('Request URL: $_baseUrl/spike/my-device');

      final response = await http.get(
        Uri.parse('$_baseUrl/spike/my-device'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('My Devices Response status: ${response.statusCode}');
      print('My Devices Response body: ${response.body}');

      // Verificar si la respuesta es HTML (error 404)
      if (response.body.trim().startsWith('<!DOCTYPE html>') || 
          response.body.trim().startsWith('<html>')) {
        return DevicesResponse.error(
          message: 'Endpoint no encontrado. Verifica la configuración del servidor.',
          statusCode: 404,
        );
      }

      final Map<String, dynamic> responseData = json.decode(response.body);

      switch (response.statusCode) {
        case 200:
          final String? error = responseData['error'];
          final bool hasError = error != null && error.isNotEmpty;

          if (!hasError) {
            // Procesar datos del dispositivo
            final List<Device> devices = _processDeviceData(responseData);
            
            // Guardar el primer dispositivo en almacenamiento seguro
            if (devices.isNotEmpty) {
              await saveDevice(devices.first);
            }
            
            return DevicesResponse.success(
              message: responseData['message'] ?? 'Dispositivo obtenido exitosamente',
              devices: devices,
            );
          } else {
            return DevicesResponse.error(
              message: error ?? 'Error al obtener el dispositivo',
            );
          }

        case 401:
          return DevicesResponse.error(
            message: 'Token de autenticación inválido o expirado',
            unauthorized: true,
            statusCode: 401,
          );

        case 404:
          return DevicesResponse.error(
            message: responseData['message'] ?? 'No se encontró el dispositivo',
            statusCode: 404,
          );

        default:
          return DevicesResponse.error(
            message: responseData['message'] ?? 
                    responseData['error'] ??
                    'Error al obtener el dispositivo - Código: ${response.statusCode}',
            statusCode: response.statusCode,
          );
      }
    } catch (e) {
      print('Error en getMyDevices: $e');
      return DevicesResponse.error(
        message: 'Error de conexión: $e',
      );
    }
  }

  // MÉTODO PARA GUARDAR DISPOSITIVO EN STORAGE
  Future<void> saveDevice(Device device) async {
    try {
      await _secureStorage.write(
        key: _deviceStorageKey,
        value: json.encode(device.toJson()),
      );
      // print('Dispositivo guardado: ${device.name}');
    } catch (e) {
      print('Error guardando dispositivo: $e');
    }
  }

  // MÉTODO PARA OBTENER DISPOSITIVO GUARDADO DESDE STORAGE
  Future<Device?> getSavedDevice() async {
    try {
      final String? deviceJson = await _secureStorage.read(key: _deviceStorageKey);
      
      if (deviceJson != null && deviceJson.isNotEmpty) {
        return Device.fromJson(json.decode(deviceJson));
      }
      
      return null;
    } catch (e) {
      print('Error obteniendo dispositivo guardado: $e');
      return null;
    }
  }

  // MÉTODO PARA VERIFICAR SI HAY DISPOSITIVO GUARDADO
  Future<bool> hasSavedDevice() async {
    final device = await getSavedDevice();
    return device != null;
  }

  // MÉTODO PARA LIMPIAR DISPOSITIVO GUARDADO
  Future<void> clearSavedDevice() async {
    try {
      await _secureStorage.delete(key: _deviceStorageKey);
      print('Dispositivo eliminado del storage');
    } catch (e) {
      print('Error limpiando dispositivo: $e');
    }
  }

  // MÉTODO DE COMPATIBILIDAD
  Future<DevicesResponse> myDevice() async {
    return await getMyDevices();
  }

  // VERIFICAR SI HAY DISPOSITIVO CONECTADO
  Future<bool> hasConnectedDevice() async {
    final device = await getSavedDevice();
    return device != null && device.isConnected == true;
  }

  // MÉTODOS AUXILIARES
  List<Device> _processDeviceData(Map<String, dynamic> responseData) {
    final List<Device> devices = [];
    
    // Caso 1: Datos en responseData['data']
    if (responseData['data'] != null) {
      if (responseData['data'] is Map) {
        // Si es un solo dispositivo como objeto
        devices.add(Device.fromJson(responseData['data']));
      } else if (responseData['data'] is List) {
        // Si es una lista de dispositivos
        for (final deviceData in responseData['data']) {
          devices.add(Device.fromJson(deviceData));
        }
      }
    } 
    // Caso 2: Datos directamente en la respuesta
    else if (responseData['id'] != null) {
      devices.add(Device.fromJson(responseData));
    }
    
    return devices;
  }

  // VERIFICAR SI HAY TOKEN VÁLIDO
  Future<bool> hasValidToken() async {
    try {
      final String? token = await _secureStorage.read(key: 'jwt_token');
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // OBTENER TOKEN (PARA DEBUGGING)
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }
}