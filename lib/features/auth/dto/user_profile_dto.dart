class UserProfileData {
  final String id;
  final String username;
  final String? email;
  final double? height;
  final double? weight;
  final String language;
  final String? avatar;
  final String? birthDate;
  final String gender;
  final int? age;
  final bool isComplete;
  final double profileCompletionPercentage;

  UserProfileData({
    required this.id,
    required this.username,
    this.email,
    this.height,
    this.weight,
    required this.language,
    this.avatar,
    this.birthDate,
    required this.gender,
    this.age,
    required this.isComplete,
    required this.profileCompletionPercentage,
  });

  // Método fromJson para crear una instancia desde un Map
  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    return UserProfileData(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String?,
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      language: json['language'] as String,
      avatar: json['avatar'] as String?,
      birthDate: json['birth_date'] as String?,
      gender: json['gender'] as String,
      age: json['age'] != null ? (json['age'] as int) : null,
      isComplete: json['is_complete'] as bool,
      profileCompletionPercentage: (json['profile_completion_percentage'] as num).toDouble(),
    );
  }

  // Método toJson para convertir la instancia a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'height': height,
      'weight': weight,
      'language': language,
      'avatar': avatar,
      'birth_date': birthDate,
      'gender': gender,
      'age': age,
      'is_complete': isComplete,
      'profile_completion_percentage': profileCompletionPercentage,
    };
  }

  // Método copyWith para crear copias modificadas
  UserProfileData copyWith({
    String? id,
    String? username,
    String? email,
    double? height,
    double? weight,
    String? language,
    String? avatar,
    String? birthDate,
    String? gender,
    int? age,
    bool? isComplete,
    double? profileCompletionPercentage,
  }) {
    return UserProfileData(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      language: language ?? this.language,
      avatar: avatar ?? this.avatar,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      isComplete: isComplete ?? this.isComplete,
      profileCompletionPercentage: profileCompletionPercentage ?? this.profileCompletionPercentage,
    );
  }

  @override
  String toString() {
    return 'UserProfileData{id: $id, username: $username, email: $email, height: $height, weight: $weight, language: $language, avatar: $avatar, birthDate: $birthDate, gender: $gender, age: $age, isComplete: $isComplete, profileCompletionPercentage: $profileCompletionPercentage}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          username == other.username &&
          email == other.email &&
          height == other.height &&
          weight == other.weight &&
          language == other.language &&
          avatar == other.avatar &&
          birthDate == other.birthDate &&
          gender == other.gender &&
          age == other.age &&
          isComplete == other.isComplete &&
          profileCompletionPercentage == other.profileCompletionPercentage;

  @override
  int get hashCode =>
      id.hashCode ^
      username.hashCode ^
      email.hashCode ^
      height.hashCode ^
      weight.hashCode ^
      language.hashCode ^
      avatar.hashCode ^
      birthDate.hashCode ^
      gender.hashCode ^
      age.hashCode ^
      isComplete.hashCode ^
      profileCompletionPercentage.hashCode;
}