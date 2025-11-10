// class Profile {
//   String user;
//   String email;
//   String password;
//   String gender;
//   double height;
//   double weight;
//   DateTime birthDate;

//   Profile({
//     required this.user,
//     required this.email,
//     required this.password,
//     required this.gender,
//     required this.height,
//     required this.weight,
//     required this.birthDate,
//   });

//   // Método para copiar el objeto
//   Profile copyWith({
//     String? user,
//     String? email,
//     String? password,
//     String? gender,
//     double? height,
//     double? weight,
//     DateTime? birthDate,
//   }) {
//     return Profile(
//       user: user ?? this.user,
//       email: email ?? this.email,
//       password: password ?? this.password,
//       gender: gender ?? this.gender,
//       height: height ?? this.height,
//       weight: weight ?? this.weight,
//       birthDate: birthDate ?? this.birthDate,
//     );
//   }

//   // Convertir a Map
//   Map<String, dynamic> toMap() {
//     return {
//       'user': user,
//       'email': email,
//       'password': password,
//       'gender': gender,
//       'height': height,
//       'weight': weight,
//       'birthDate': birthDate.toIso8601String(),
//     };
//   }

//   // Crear desde Map
//   factory Profile.fromMap(Map<String, dynamic> map) {
//     return Profile(
//       user: map['user'] ?? '',
//       email: map['email'] ?? '',
//       password: map['password'] ?? '',
//       gender: map['gender'] ?? '',
//       height: map['height']?.toDouble() ?? 0.0,
//       weight: map['weight']?.toDouble() ?? 0.0,
//       birthDate: DateTime.parse(map['birthDate']),
//     );
//   }
// }