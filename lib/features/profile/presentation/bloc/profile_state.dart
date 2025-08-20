import 'package:equatable/equatable.dart';

import '../../domain/entities/user_profile.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;

  const ProfileLoaded({required this.profile});

  @override
  List<Object> get props => [profile];
}

class ProfileUpdating extends ProfileState {
  final UserProfile profile;

  const ProfileUpdating({required this.profile});

  @override
  List<Object> get props => [profile];
}

class ProfileUpdated extends ProfileState {
  final UserProfile profile;

  const ProfileUpdated({required this.profile});

  @override
  List<Object> get props => [profile];
}

class ProfilePictureUploading extends ProfileState {
  final UserProfile profile;

  const ProfilePictureUploading({required this.profile});

  @override
  List<Object> get props => [profile];
}

class ProfilePictureUploaded extends ProfileState {
  final UserProfile profile;
  final String imageUrl;

  const ProfilePictureUploaded({
    required this.profile,
    required this.imageUrl,
  });

  @override
  List<Object> get props => [profile, imageUrl];
}

class ProfilePictureDeleted extends ProfileState {
  final UserProfile profile;

  const ProfilePictureDeleted({required this.profile});

  @override
  List<Object> get props => [profile];
}

class PasswordUpdating extends ProfileState {}

class PasswordUpdated extends ProfileState {}

class PasswordResetEmailSent extends ProfileState {}

class EmailVerificationSent extends ProfileState {}

class EmailUpdating extends ProfileState {}

class EmailUpdated extends ProfileState {}

class AccountDeleting extends ProfileState {}

class AccountDeleted extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object> get props => [message];
}
