import 'package:hive/hive.dart';

class User {
  final int? id;
  final String name;
  final String? gender;
  final String email;
  final String studentId;
  final int? level;
  final String password;
  final String? profilePhoto;

  User({
    this.id,
    required this.name,
    this.gender,
    required this.email,
    required this.studentId,
    this.level,
    required this.password,
    this.profilePhoto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'email': email,
      'studentId': studentId,
      'level': level,
      'password': password,
      'profilePhoto': profilePhoto,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      gender: map['gender'],
      email: map['email'],
      studentId: map['studentId'],
      level: map['level'],
      password: map['password'],
      profilePhoto: map['profilePhoto'],
    );
  }

  User copyWith({
    int? id,
    String? name,
    String? gender,
    String? email,
    String? studentId,
    int? level,
    String? password,
    String? profilePhoto,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      studentId: studentId ?? this.studentId,
      level: level ?? this.level,
      password: password ?? this.password,
      profilePhoto: profilePhoto ?? this.profilePhoto,
    );
  }
}
