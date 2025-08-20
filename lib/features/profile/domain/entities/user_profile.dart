import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? bio;
  final String? profilePictureUrl;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEmailVerified;
  final Map<String, dynamic> preferences;
  final Map<String, dynamic> settings;

  const UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.bio,
    this.profilePictureUrl,
    this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
    this.isEmailVerified = false,
    this.preferences = const {},
    this.settings = const {},
  });

  UserProfile copyWith({
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
    return UserProfile(
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

  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      final names = displayName!.split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      }
      return displayName![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  bool get hasProfilePicture => profilePictureUrl != null && profilePictureUrl!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        bio,
        profilePictureUrl,
        phoneNumber,
        createdAt,
        updatedAt,
        isEmailVerified,
        preferences,
        settings,
      ];

  @override
  String toString() {
    return 'UserProfile(id: $id, email: $email, displayName: $displayName, bio: $bio, profilePictureUrl: $profilePictureUrl, phoneNumber: $phoneNumber, createdAt: $createdAt, updatedAt: $updatedAt, isEmailVerified: $isEmailVerified, preferences: $preferences, settings: $settings)';
  }
}
