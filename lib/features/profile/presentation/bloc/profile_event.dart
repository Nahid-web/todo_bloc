import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../domain/entities/user_profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends ProfileEvent {
  final String userId;

  const LoadUserProfile({required this.userId});

  @override
  List<Object> get props => [userId];
}

class UpdateUserProfile extends ProfileEvent {
  final UserProfile profile;

  const UpdateUserProfile({required this.profile});

  @override
  List<Object> get props => [profile];
}

class UploadProfilePicture extends ProfileEvent {
  final String userId;
  final File imageFile;

  const UploadProfilePicture({
    required this.userId,
    required this.imageFile,
  });

  @override
  List<Object> get props => [userId, imageFile];
}

class DeleteProfilePicture extends ProfileEvent {
  final String userId;

  const DeleteProfilePicture({required this.userId});

  @override
  List<Object> get props => [userId];
}

class UpdatePassword extends ProfileEvent {
  final String currentPassword;
  final String newPassword;

  const UpdatePassword({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [currentPassword, newPassword];
}

class SendPasswordResetEmail extends ProfileEvent {
  final String email;

  const SendPasswordResetEmail({required this.email});

  @override
  List<Object> get props => [email];
}

class SendEmailVerification extends ProfileEvent {}

class UpdateEmail extends ProfileEvent {
  final String newEmail;
  final String password;

  const UpdateEmail({
    required this.newEmail,
    required this.password,
  });

  @override
  List<Object> get props => [newEmail, password];
}

class DeleteUserAccount extends ProfileEvent {
  final String userId;

  const DeleteUserAccount({required this.userId});

  @override
  List<Object> get props => [userId];
}

class ResetProfileState extends ProfileEvent {}
