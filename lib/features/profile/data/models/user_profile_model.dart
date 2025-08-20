import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.email,
    super.displayName,
    super.bio,
    super.profilePictureUrl,
    super.phoneNumber,
    required super.createdAt,
    required super.updatedAt,
    super.isEmailVerified = false,
    super.preferences = const {},
    super.settings = const {},
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      bio: json['bio'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      preferences: Map<String, dynamic>.from(json['preferences'] as Map? ?? {}),
      settings: Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'bio': bio,
      'profilePictureUrl': profilePictureUrl,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'preferences': preferences,
      'settings': settings,
    };
  }

  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      id: profile.id,
      email: profile.email,
      displayName: profile.displayName,
      bio: profile.bio,
      profilePictureUrl: profile.profilePictureUrl,
      phoneNumber: profile.phoneNumber,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
      isEmailVerified: profile.isEmailVerified,
      preferences: profile.preferences,
      settings: profile.settings,
    );
  }

  factory UserProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfileModel(
      id: doc.id,
      email: data['email'] as String,
      displayName: data['displayName'] as String?,
      bio: data['bio'] as String?,
      profilePictureUrl: data['profilePictureUrl'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isEmailVerified: data['isEmailVerified'] as bool? ?? false,
      preferences: Map<String, dynamic>.from(data['preferences'] as Map? ?? {}),
      settings: Map<String, dynamic>.from(data['settings'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'bio': bio,
      'profilePictureUrl': profilePictureUrl,
      'phoneNumber': phoneNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isEmailVerified': isEmailVerified,
      'preferences': preferences,
      'settings': settings,
    };
  }

  @override
  UserProfileModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? bio,
    String? profilePictureUrl,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? settings,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      preferences: preferences ?? this.preferences,
      settings: settings ?? this.settings,
    );
  }
}
