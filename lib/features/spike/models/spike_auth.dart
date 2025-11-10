class HmacAuthResponse {
  final String accessToken;
  final UserInfo userInfo;

  HmacAuthResponse({
    required this.accessToken,
    required this.userInfo,
  });

  factory HmacAuthResponse.fromJson(Map<String, dynamic> json) {
    return HmacAuthResponse(
      accessToken: json['access_token'] as String,
      userInfo: UserInfo.fromJson(json['user_info'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'user_info': userInfo.toJson(),
    };
  }

  @override
  String toString() {
    return 'HmacAuthResponse{accessToken: $accessToken, userInfo: $userInfo}';
  }
}

class UserInfo {
  final int applicationId;
  final String applicationUserId;
  final String uid;
  final String compatApplicationClientToken;
  final String compatApplicationClientId;
  final dynamic integratedProviders;
  final DateTime? createdAt;

  UserInfo({
    required this.applicationId,
    required this.applicationUserId,
    required this.uid,
    required this.compatApplicationClientToken,
    required this.compatApplicationClientId,
    required this.integratedProviders,
    this.createdAt,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      applicationId: json['application_id'] as int,
      applicationUserId: json['application_user_id'] as String,
      uid: json['uid'] as String,
      compatApplicationClientToken: json['compat_application_client_token'] as String,
      compatApplicationClientId: json['compat_application_client_id'] as String,
      integratedProviders: json['integrated_providers'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'application_id': applicationId,
      'application_user_id': applicationUserId,
      'uid': uid,
      'compat_application_client_token': compatApplicationClientToken,
      'compat_application_client_id': compatApplicationClientId,
      'integrated_providers': integratedProviders,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'UserInfo{applicationId: $applicationId, applicationUserId: $applicationUserId, uid: $uid, compatApplicationClientToken: $compatApplicationClientToken, compatApplicationClientId: $compatApplicationClientId, integratedProviders: $integratedProviders, createdAt: $createdAt}';
  }
}