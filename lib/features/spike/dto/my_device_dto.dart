class MyDeviceResponse {
  final bool hasDevice;
  final MyDeviceData? device;

  MyDeviceResponse({
    required this.hasDevice,
    this.device,
  });

  factory MyDeviceResponse.fromJson(Map<String, dynamic> json) {
    // El backend devuelve {"data": {...}} o {"data": null}
    final data = json['data'];
    return MyDeviceResponse(
      hasDevice: data != null,
      device: data != null ? MyDeviceData.fromJson(data) : null,
    );
  }
}

class MyDeviceData {
  final int id;
  final String spikeIdHash;
  final String provider;
  final bool isActive;
  final bool consentGiven;
  final DateTime? lastFetchedAt;

  MyDeviceData({
    required this.id,
    required this.spikeIdHash,
    required this.provider,
    required this.isActive,
    required this.consentGiven,
    this.lastFetchedAt,
  });

  factory MyDeviceData.fromJson(Map<String, dynamic> json) {
    // Helper para parsear booleanos de forma segura
    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value != 0;
      if (value is String) return value.toLowerCase() == 'true' || value == '1';
      return false;
    }

    return MyDeviceData(
      id: (json['id'] as num?)?.toInt() ?? 0,
      spikeIdHash: json['spike_id_hash']?.toString() ?? '',
      provider: json['provider']?.toString() ?? '',
      isActive: parseBool(json['is_active']),
      consentGiven: parseBool(json['consent_given']),
      lastFetchedAt: json['last_fetched_at'] != null 
          ? DateTime.tryParse(json['last_fetched_at'].toString()) 
          : null,
    );
  }
}
