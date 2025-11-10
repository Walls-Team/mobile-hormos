class ProviderIntegrationInit {
  final String providerSlug;
  final String path;

  ProviderIntegrationInit({
    required this.providerSlug,
    required this.path,
  });

  factory ProviderIntegrationInit.fromJson(Map<String, dynamic> json) {
    return ProviderIntegrationInit(
      providerSlug: json['provider_slug'] as String,
      path: json['path'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider_slug': providerSlug,
      'path': path,
    };
  }
}