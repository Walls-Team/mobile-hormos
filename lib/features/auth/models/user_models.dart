// class User {
//   final String id;
//   final String username;
//   final String email;
//   final int? height;
//   final double? weight;
//   final String language;
//   final String? avatar;
//   final String? birthDate;
//   final String gender;
//   final int? age;
//   final bool isComplete;
//   final int profileCompletionPercentage;

//   User({
//     required this.id,
//     required this.username,
//     required this.email,
//     this.height,
//     this.weight,
//     this.language = 'es',
//     this.avatar,
//     this.birthDate,
//     this.gender = '',
//     this.age,
//     this.isComplete = false,
//     this.profileCompletionPercentage = 0,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id']?.toString() ?? '',
//       username: json['username'] ?? '',
//       email: json['email'] ?? '',
//       height: json['height'],
//       weight: json['weight']?.toDouble(),
//       language: json['language'] ?? 'es',
//       avatar: json['avatar'],
//       birthDate: json['birth_date'],
//       gender: json['gender'] ?? '',
//       age: json['age'],
//       isComplete: json['is_complete'] ?? false,
//       profileCompletionPercentage: json['profile_completion_percentage'] ?? 0,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'username': username,
//       'email': email,
//       'height': height,
//       'weight': weight,
//       'language': language,
//       'avatar': avatar,
//       'birth_date': birthDate,
//       'gender': gender,
//       'age': age,
//       'is_complete': isComplete,
//       'profile_completion_percentage': profileCompletionPercentage,
//     };
//   }

//   User copyWith({
//     String? id,
//     String? username,
//     String? email,
//     int? height,
//     double? weight,
//     String? language,
//     String? avatar,
//     String? birthDate,
//     String? gender,
//     int? age,
//     bool? isComplete,
//     int? profileCompletionPercentage,
//   }) {
//     return User(
//       id: id ?? this.id,
//       username: username ?? this.username,
//       email: email ?? this.email,
//       height: height ?? this.height,
//       weight: weight ?? this.weight,
//       language: language ?? this.language,
//       avatar: avatar ?? this.avatar,
//       birthDate: birthDate ?? this.birthDate,
//       gender: gender ?? this.gender,
//       age: age ?? this.age,
//       isComplete: isComplete ?? this.isComplete,
//       profileCompletionPercentage: profileCompletionPercentage ?? this.profileCompletionPercentage,
//     );
//   }

//   bool get isProfileComplete {
//     return isComplete || profileCompletionPercentage >= 80;
//   }

//   List<String> get missingFields {
//     final List<String> missing = [];
    
//     if (height == null || height! <= 0) missing.add('Altura');
//     if (weight == null || weight! <= 0) missing.add('Peso');
//     if (birthDate == null || birthDate!.isEmpty) missing.add('Fecha de nacimiento');
//     if (gender.isEmpty) missing.add('Género');
//     if (age == null || age! <= 0) missing.add('Edad');
    
//     return missing;
//   }
// }

// // models/auth_response.dart
// class AuthResponse {
//   final bool success;
//   final String message;
//   final User? user;
//   final String? error;
//   final String? token;

//   AuthResponse({
//     required this.success,
//     required this.message,
//     this.user,
//     this.error,
//     this.token,
//   });

//   factory AuthResponse.success({
//     required String message,
//     User? user,
//     String? token,
//   }) {
//     return AuthResponse(
//       success: true,
//       message: message,
//       user: user,
//       token: token,
//     );
//   }

//   factory AuthResponse.error({
//     required String message,
//     String? error,
//   }) {
//     return AuthResponse(
//       success: false,
//       message: message,
//       error: error ?? message,
//     );
//   }
// }
