import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    super.email,
    super.displayName,
    required super.isAnonymous,
    required super.createdAt,
    required super.lastSignInAt,
  });

  factory UserModel.fromFirebaseUser(firebase_auth.User firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      isAnonymous: firebaseUser.isAnonymous,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastSignInAt: firebaseUser.metadata.lastSignInTime ?? DateTime.now(),
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      isAnonymous: json['isAnonymous'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastSignInAt: DateTime.parse(json['lastSignInAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'isAnonymous': isAnonymous,
      'createdAt': createdAt.toIso8601String(),
      'lastSignInAt': lastSignInAt.toIso8601String(),
    };
  }

  @override
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    bool? isAnonymous,
    DateTime? createdAt,
    DateTime? lastSignInAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
    );
  }
}
