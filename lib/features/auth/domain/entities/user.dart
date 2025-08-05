import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String? email;
  final String? displayName;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime lastSignInAt;

  const User({
    required this.id,
    this.email,
    this.displayName,
    required this.isAnonymous,
    required this.createdAt,
    required this.lastSignInAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    bool? isAnonymous,
    DateTime? createdAt,
    DateTime? lastSignInAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        isAnonymous,
        createdAt,
        lastSignInAt,
      ];

  @override
  String toString() {
    return 'User(id: $id, email: $email, displayName: $displayName, isAnonymous: $isAnonymous, createdAt: $createdAt, lastSignInAt: $lastSignInAt)';
  }
}
