import 'package:flutter/foundation.dart';
import 'package:genius_hormo/features/auth/dto/user_profile_dto.dart';
import 'package:genius_hormo/features/auth/services/auth_service.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/features/spike/dto/my_device_dto.dart';
import 'package:genius_hormo/features/spike/services/spike_providers.dart';
import 'package:get_it/get_it.dart';

/// Modelo que representa el estado del setup
class SetupStatus {
  final bool hasProfile;
  final bool hasDevice;
  final UserProfileData? profile;
  final MyDeviceResponse? device;
  final bool isLoading;
  final String? error;

  SetupStatus({
    required this.hasProfile,
    required this.hasDevice,
    this.profile,
    this.device,
    this.isLoading = false,
    this.error,
  });

  /// Setup está completo cuando ambos: perfil y dispositivo están listos
  bool get isComplete => hasProfile && hasDevice;

  /// Setup está incompleto
  bool get isIncomplete => !isComplete;

  /// Mensaje descriptivo del estado
  String get statusMessage {
    if (isComplete) return 'Setup complete';
    if (!hasProfile && !hasDevice) return 'Complete profile and connect device';
    if (!hasProfile) return 'Complete your profile';
    if (!hasDevice) return 'Connect a device';
    return 'Setup incomplete';
  }

  SetupStatus copyWith({
    bool? hasProfile,
    bool? hasDevice,
    UserProfileData? profile,
    MyDeviceResponse? device,
    bool? isLoading,
    String? error,
  }) {
    return SetupStatus(
      hasProfile: hasProfile ?? this.hasProfile,
      hasDevice: hasDevice ?? this.hasDevice,
      profile: profile ?? this.profile,
      device: device ?? this.device,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  String toString() {
    return 'SetupStatus(hasProfile: $hasProfile, hasDevice: $hasDevice, isComplete: $isComplete)';
  }
}

/// Servicio centralizado para verificar el estado del setup del usuario
class SetupStatusService {
  final AuthService _authService = GetIt.instance<AuthService>();
  final UserStorageService _userStorageService = GetIt.instance<UserStorageService>();
  final SpikeApiService _spikeApiService = GetIt.instance<SpikeApiService>();

  /// Estado actual del setup
  SetupStatus _currentStatus = SetupStatus(
    hasProfile: false,
    hasDevice: false,
    isLoading: true,
  );

  SetupStatus get currentStatus => _currentStatus;

  /// Verifica el estado completo del setup del usuario
  /// Llama a los endpoints de perfil y dispositivo
  Future<SetupStatus> checkSetupStatus() async {
    try {
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔍 VERIFICANDO ESTADO DEL SETUP');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      _currentStatus = _currentStatus.copyWith(isLoading: true, error: null);

      // Obtener token
      final token = await _userStorageService.getJWTToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      // 1. Verificar perfil
      UserProfileData? profile;
      bool hasProfile = false;
      try {
        profile = await _authService.getMyProfile(token: token);
        hasProfile = profile.isComplete;
        
        debugPrint('✅ PERFIL:');
        debugPrint('   Completo: $hasProfile');
        debugPrint('   Porcentaje: ${profile.profileCompletionPercentage}%');
        debugPrint('   Username: ${profile.username}');
      } catch (e) {
        debugPrint('⚠️ Error al verificar perfil: $e');
        hasProfile = false;
      }

      // 2. Verificar dispositivo
      MyDeviceResponse? deviceResponse;
      bool hasDevice = false;
      try {
        final deviceResult = await _spikeApiService.getMyDevice(token: token);
        if (deviceResult.success && deviceResult.data != null) {
          deviceResponse = deviceResult.data;
          // Si hay dispositivo en la respuesta, considerarlo como conectado
          hasDevice = deviceResponse!.hasDevice;
          
          debugPrint('\n✅ DISPOSITIVO:');
          debugPrint('   Tiene dispositivo: ${deviceResponse.hasDevice}');
          if (deviceResponse.device != null) {
            debugPrint('   Device ID: ${deviceResponse.device!.id}');
            debugPrint('   Spike ID Hash: ${deviceResponse.device!.spikeIdHash}');
            debugPrint('   Provider: ${deviceResponse.device!.provider}');
            debugPrint('   Is Active: ${deviceResponse.device!.isActive}');
            debugPrint('   Consent Given: ${deviceResponse.device!.consentGiven}');
          }
        } else {
          debugPrint('\n⚠️ DISPOSITIVO: No se obtuvo respuesta exitosa');
        }
      } catch (e) {
        debugPrint('⚠️ Error al verificar dispositivo: $e');
        hasDevice = false;
      }

      final setupStatus = SetupStatus(
        hasProfile: hasProfile,
        hasDevice: hasDevice,
        profile: profile,
        device: deviceResponse,
        isLoading: false,
      );

      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📊 RESULTADO DEL SETUP');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('✅ Perfil completo: $hasProfile');
      debugPrint('✅ Dispositivo conectado: $hasDevice');
      debugPrint('🎯 Setup completo: ${setupStatus.isComplete}');
      debugPrint('📝 Mensaje: ${setupStatus.statusMessage}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      _currentStatus = setupStatus;
      return setupStatus;
    } catch (e, stackTrace) {
      debugPrint('❌ Error en checkSetupStatus: $e');
      debugPrint('StackTrace: $stackTrace');

      final errorStatus = SetupStatus(
        hasProfile: false,
        hasDevice: false,
        isLoading: false,
        error: e.toString(),
      );

      _currentStatus = errorStatus;
      return errorStatus;
    }
  }

  /// Método rápido para solo verificar si el setup está completo
  Future<bool> isSetupComplete() async {
    final status = await checkSetupStatus();
    return status.isComplete;
  }

  /// Refrescar solo el estado del perfil
  Future<void> refreshProfileStatus() async {
    try {
      final token = await _userStorageService.getJWTToken();
      if (token == null) return;

      final profile = await _authService.getMyProfile(token: token);
      _currentStatus = _currentStatus.copyWith(
        hasProfile: profile.isComplete,
        profile: profile,
      );

      debugPrint('🔄 Perfil refrescado: ${profile.isComplete}');
    } catch (e) {
      debugPrint('⚠️ Error al refrescar perfil: $e');
    }
  }

  /// Refrescar solo el estado del dispositivo
  Future<void> refreshDeviceStatus() async {
    try {
      final token = await _userStorageService.getJWTToken();
      if (token == null) return;

      final deviceResult = await _spikeApiService.getMyDevice(token: token);
      if (deviceResult.success && deviceResult.data != null) {
        final deviceResponse = deviceResult.data!;
        _currentStatus = _currentStatus.copyWith(
          hasDevice: deviceResponse.hasDevice && 
                    (deviceResponse.device?.isActive ?? false),
          device: deviceResponse,
        );

        debugPrint('🔄 Dispositivo refrescado: ${_currentStatus.hasDevice}');
      }
    } catch (e) {
      debugPrint('⚠️ Error al refrescar dispositivo: $e');
    }
  }

  /// Resetear el estado
  void reset() {
    _currentStatus = SetupStatus(
      hasProfile: false,
      hasDevice: false,
      isLoading: false,
    );
  }
}
