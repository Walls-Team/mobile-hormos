import 'package:flutter/foundation.dart';

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
    debugPrint('\n🔍 Parseando UserProfileData desde JSON:');
    debugPrint('📦 JSON recibido: $json');
    debugPrint('🔑 Keys disponibles: ${json.keys.toList()}');
    
    try {
      // Parse individual con logging
      final id = json['id']?.toString() ?? json['user_id']?.toString() ?? 'unknown';
      final username = json['username']?.toString() ?? json['name']?.toString() ?? 'unknown';
      final email = json['email']?.toString();
      
      debugPrint('📝 Parseando height: ${json['height']} (tipo: ${json['height']?.runtimeType})');
      // Altura viene como string "70.00" en PULGADAS desde el backend
      final heightStr = json['height']?.toString();
      // IMPORTANTE: Guardamos la altura directamente en PULGADAS
      final height = heightStr != null ? double.tryParse(heightStr) : null;
      debugPrint('   → Altura parseada y guardada en PULGADAS: $height');
      
      debugPrint('📝 Parseando weight: ${json['weight']} (tipo: ${json['weight']?.runtimeType})');
      // Peso viene como string "40.00" en libras desde el backend
      final weightStr = json['weight']?.toString();
      final weight = weightStr != null ? double.tryParse(weightStr) : null;
      debugPrint('   → Peso parseado: $weight libras');
      
      final language = json['language']?.toString() ?? 'es';
      final avatar = json['avatar']?.toString();
      final birthDate = json['birth_date']?.toString() ?? json['birthDate']?.toString();
      final gender = json['gender']?.toString() ?? 'unknown';
      final age = json['age'] != null ? int.tryParse(json['age'].toString()) : null;
      final isComplete = json['is_complete'] == true || json['isComplete'] == true;
      
      debugPrint('📝 Parseando completion %: ${json['profile_completion_percentage']} (tipo: ${json['profile_completion_percentage'].runtimeType})');
      final profileCompletionPercentage = json['profile_completion_percentage'] != null 
          ? double.tryParse(json['profile_completion_percentage'].toString()) ?? 0.0
          : 0.0;
      
      debugPrint('\n✅ Valores parseados:');
      debugPrint('   id: $id');
      debugPrint('   username: $username');
      debugPrint('   email: $email');
      debugPrint('   height: $height');
      debugPrint('   weight: $weight');
      debugPrint('   avatar: $avatar');
      debugPrint('   gender: $gender');
      debugPrint('   age: $age\n');
      
      final profileData = UserProfileData(
        id: id,
        username: username,
        email: email,
        height: height,
        weight: weight,
        language: language,
        avatar: avatar,
        birthDate: birthDate,
        gender: gender,
        age: age,
        isComplete: isComplete,
        profileCompletionPercentage: profileCompletionPercentage,
      );
      
      debugPrint('✅ UserProfileData creado exitosamente: ${profileData.username}');
      return profileData;
    } catch (e, stackTrace) {
      debugPrint('❌ Error parseando UserProfileData: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      rethrow;
    }
  }

  // Método toJson para convertir la instancia a Map
  Map<String, dynamic> toJson() {
    debugPrint('\n📦 Converting UserProfileData to JSON...');
    debugPrint('  Height value: $height (type: ${height.runtimeType})');
    debugPrint('  Weight value: $weight (type: ${weight.runtimeType})');
    
    // Backend requiere altura y peso como strings en unidades imperiales
    // Altura en PULGADAS ("70.00") y peso en libras ("150.00")
    
    // IMPORTANTE: El valor de height ya viene en PULGADAS, no en pies
    // Por lo que solo necesitamos convertirlo a string con formato
    final heightStr = (height ?? 0.0).toStringAsFixed(2);
    
    // El peso ya está en libras
    final weightStr = weight?.toStringAsFixed(2) ?? "0.00";
    
    debugPrint('   → Enviando altura: $height pulgadas ("$heightStr")');
    debugPrint('   → Enviando peso: $weight libras ("$weightStr")');
    
    debugPrint('  Height string: $heightStr pulgadas');
    debugPrint('  Weight string: $weightStr lbs');
    
    return {
      'id': id,
      'username': username,
      'email': email,
      'height': heightStr,
      'weight': weightStr,
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