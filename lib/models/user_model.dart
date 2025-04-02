import '../utils/date_helpers.dart';

class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? photoURL;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.photoURL,
    required this.createdAt,
  });

  // Conversión desde Map (JSON/Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      photoURL: map['photoURL'],
      createdAt: DateHelpers.parseDateTime(map['createdAt']),
    );
  }

  // Conversión a Map (para Firestore/JSON)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoURL': photoURL,
      'createdAt': createdAt.toIso8601String(), // DateTime a String ISO
    };
  }

}