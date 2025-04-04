import '../utils/date_helpers.dart';

class UserModel {
  final String userId;
  final String name;
  final String email;
  final DateTime createdAt;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  // Conversión desde Map (JSON/Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['uid'],
      email: map['email'],
      name: map['name'],
      createdAt: DateHelpers.parseDateTime(map['createdAt']),
    );
  }

  // Conversión a Map (para Firestore/JSON)
  Map<String, dynamic> toMap() {
    return {
      'uid': userId,
      'email': email,
      'name': name,
      'createdAt': createdAt.toIso8601String(), // DateTime a String ISO
    };
  }

}