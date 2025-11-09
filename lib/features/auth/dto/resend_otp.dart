class ResendOtpResponseData {
  final String message;

  ResendOtpResponseData({required this.message});

  factory ResendOtpResponseData.fromJson(Map<String, dynamic> json) =>
      ResendOtpResponseData(message: json['message'] as String);

  Map<String, dynamic> toJson() => {'message': message};

  @override
  String toString() => 'ResendOtpResponseData(message: $message)';
}