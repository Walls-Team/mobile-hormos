// models/device_model.dart
class Device {
  final String id;
  final String spikeIdHash;
  final String provider;
  final bool isActive;
  final bool consentGiven;
  final DateTime lastFetchedAt;

  Device({
    required this.id,
    required this.spikeIdHash,
    required this.provider,
    required this.isActive,
    required this.consentGiven,
    required this.lastFetchedAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id']?.toString() ?? '',
      spikeIdHash: json['spike_id_hash'] ?? '',
      provider: json['provider'] ?? '',
      isActive: json['is_active'] ?? false,
      consentGiven: json['consent_given'] ?? false,
      lastFetchedAt: DateTime.parse(json['last_fetched_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'spike_id_hash': spikeIdHash,
      'provider': provider,
      'is_active': isActive,
      'consent_given': consentGiven,
      'last_fetched_at': lastFetchedAt.toIso8601String(),
    };
  }

  Device copyWith({
    String? id,
    String? spikeIdHash,
    String? provider,
    bool? isActive,
    bool? consentGiven,
    DateTime? lastFetchedAt,
  }) {
    return Device(
      id: id ?? this.id,
      spikeIdHash: spikeIdHash ?? this.spikeIdHash,
      provider: provider ?? this.provider,
      isActive: isActive ?? this.isActive,
      consentGiven: consentGiven ?? this.consentGiven,
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
    );
  }

  bool get isConnected => isActive && consentGiven;
  
  String get status {
    if (!isActive) return 'Inactivo';
    if (!consentGiven) return 'Pendiente de consentimiento';
    return 'Conectado';
  }
}

// models/devices_response.dart
class DevicesResponse {
  final bool success;
  final String message;
  final List<Device>? devices;
  final String? error;
  final bool? unauthorized;
  final int? statusCode;

  DevicesResponse({
    required this.success,
    required this.message,
    this.devices,
    this.error,
    this.unauthorized,
    this.statusCode,
  });

  factory DevicesResponse.success({
    required String message,
    required List<Device> devices,
  }) {
    return DevicesResponse(
      success: true,
      message: message,
      devices: devices,
    );
  }

  factory DevicesResponse.error({
    required String message,
    String? error,
    bool? unauthorized,
    int? statusCode,
  }) {
    return DevicesResponse(
      success: false,
      message: message,
      error: error ?? message,
      unauthorized: unauthorized,
      statusCode: statusCode,
    );
  }

  bool get hasDevices => devices != null && devices!.isNotEmpty;
  Device? get activeDevice => devices?.firstWhere(
    (device) => device.isActive,
    orElse: () => devices?.first ?? Device(
      id: '',
      spikeIdHash: '',
      provider: '',
      isActive: false,
      consentGiven: false,
      lastFetchedAt: DateTime.now(),
    ),
  );
}