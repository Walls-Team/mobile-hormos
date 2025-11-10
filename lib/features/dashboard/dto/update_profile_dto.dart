class UpdateProfileResponseData {
  final String message;

  UpdateProfileResponseData({required this.message});

  factory UpdateProfileResponseData.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponseData(message: json['message'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'message': message};
  }

  @override
  String toString() {
    return 'UpdateProfileResponseData{message: $message}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateProfileResponseData &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  UpdateProfileResponseData copyWith({String? message}) {
    return UpdateProfileResponseData(message: message ?? this.message);
  }
}
