import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/logging/app_logger.dart';
import '../../domain/usecases/delete_profile_picture.dart' as usecases;
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/update_password.dart' as usecases;
import '../../domain/usecases/update_user_profile.dart' as usecases;
import '../../domain/usecases/upload_profile_picture.dart' as usecases;
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfile getUserProfile;
  final usecases.UpdateUserProfile updateUserProfile;
  final usecases.UploadProfilePicture uploadProfilePicture;
  final usecases.DeleteProfilePicture deleteProfilePicture;
  final usecases.UpdatePassword updatePassword;

  ProfileBloc({
    required this.getUserProfile,
    required this.updateUserProfile,
    required this.uploadProfilePicture,
    required this.deleteProfilePicture,
    required this.updatePassword,
  }) : super(ProfileInitial()) {
    AppLogger.logBloc('ProfileBloc', 'Initializing ProfileBloc');

    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<UploadProfilePicture>(_onUploadProfilePicture);
    on<DeleteProfilePicture>(_onDeleteProfilePicture);
    on<UpdatePassword>(_onUpdatePassword);
    on<ResetProfileState>(_onResetProfileState);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    AppLogger.logBloc(
      'ProfileBloc',
      'LoadUserProfile',
      eventData: {'userId': event.userId},
    );

    emit(ProfileLoading());

    final result = await getUserProfile(
      GetUserProfileParams(userId: event.userId),
    );

    result.fold(
      (failure) {
        AppLogger.logBloc(
          'ProfileBloc',
          'LoadUserProfile',
          error: failure.toString(),
        );
        emit(ProfileError(message: failure.toString()));
      },
      (profile) {
        AppLogger.logBloc(
          'ProfileBloc',
          'LoadUserProfile',
          newState: 'ProfileLoaded',
          eventData: {
            'userId': profile.id,
            'email': profile.email,
            'displayName': profile.displayName,
          },
        );
        emit(ProfileLoaded(profile: profile));
      },
    );
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    AppLogger.logBloc(
      'ProfileBloc',
      'UpdateUserProfile',
      eventData: {
        'userId': event.profile.id,
        'displayName': event.profile.displayName,
        'bio': event.profile.bio,
      },
    );

    emit(ProfileUpdating(profile: event.profile));

    final result = await updateUserProfile(
      usecases.UpdateUserProfileParams(profile: event.profile),
    );

    result.fold(
      (failure) {
        AppLogger.logBloc(
          'ProfileBloc',
          'UpdateUserProfile',
          error: failure.toString(),
        );
        emit(ProfileError(message: failure.toString()));
      },
      (updatedProfile) {
        AppLogger.logBloc(
          'ProfileBloc',
          'UpdateUserProfile',
          newState: 'ProfileUpdated',
          eventData: {
            'userId': updatedProfile.id,
            'displayName': updatedProfile.displayName,
            'bio': updatedProfile.bio,
          },
        );
        emit(ProfileUpdated(profile: updatedProfile));
      },
    );
  }

  Future<void> _onUploadProfilePicture(
    UploadProfilePicture event,
    Emitter<ProfileState> emit,
  ) async {
    AppLogger.logBloc(
      'ProfileBloc',
      'UploadProfilePicture',
      eventData: {
        'userId': event.userId,
        'fileSize': event.imageFile.lengthSync(),
        'fileName': event.imageFile.path.split('/').last,
      },
    );

    if (state is ProfileLoaded) {
      final currentProfile = (state as ProfileLoaded).profile;
      emit(ProfilePictureUploading(profile: currentProfile));

      final result = await uploadProfilePicture(
        usecases.UploadProfilePictureParams(
          userId: event.userId,
          imageFile: event.imageFile,
        ),
      );

      result.fold(
        (failure) {
          AppLogger.logBloc(
            'ProfileBloc',
            'UploadProfilePicture',
            error: failure.toString(),
          );
          emit(ProfileError(message: failure.toString()));
        },
        (imageUrl) {
          AppLogger.logBloc(
            'ProfileBloc',
            'UploadProfilePicture',
            newState: 'ProfilePictureUploaded',
            eventData: {'userId': event.userId, 'imageUrl': imageUrl},
          );

          final updatedProfile = currentProfile.copyWith(
            profilePictureUrl: imageUrl,
            updatedAt: DateTime.now(),
          );

          emit(
            ProfilePictureUploaded(profile: updatedProfile, imageUrl: imageUrl),
          );
        },
      );
    } else {
      emit(const ProfileError(message: 'Profile not loaded'));
    }
  }

  Future<void> _onDeleteProfilePicture(
    DeleteProfilePicture event,
    Emitter<ProfileState> emit,
  ) async {
    AppLogger.logBloc(
      'ProfileBloc',
      'DeleteProfilePicture',
      eventData: {'userId': event.userId},
    );

    if (state is ProfileLoaded) {
      final currentProfile = (state as ProfileLoaded).profile;

      final result = await deleteProfilePicture(
        usecases.DeleteProfilePictureParams(userId: event.userId),
      );

      result.fold(
        (failure) {
          AppLogger.logBloc(
            'ProfileBloc',
            'DeleteProfilePicture',
            error: failure.toString(),
          );
          emit(ProfileError(message: failure.toString()));
        },
        (_) {
          AppLogger.logBloc(
            'ProfileBloc',
            'DeleteProfilePicture',
            newState: 'ProfilePictureDeleted',
            eventData: {'userId': event.userId},
          );

          final updatedProfile = currentProfile.copyWith(
            profilePictureUrl: null,
            updatedAt: DateTime.now(),
          );

          emit(ProfilePictureDeleted(profile: updatedProfile));
        },
      );
    } else {
      emit(const ProfileError(message: 'Profile not loaded'));
    }
  }

  Future<void> _onUpdatePassword(
    UpdatePassword event,
    Emitter<ProfileState> emit,
  ) async {
    AppLogger.logBloc('ProfileBloc', 'UpdatePassword');

    emit(PasswordUpdating());

    final result = await updatePassword(
      usecases.UpdatePasswordParams(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.logBloc(
          'ProfileBloc',
          'UpdatePassword',
          error: failure.toString(),
        );
        emit(ProfileError(message: failure.toString()));
      },
      (_) {
        AppLogger.logBloc(
          'ProfileBloc',
          'UpdatePassword',
          newState: 'PasswordUpdated',
        );
        emit(PasswordUpdated());
      },
    );
  }

  void _onResetProfileState(
    ResetProfileState event,
    Emitter<ProfileState> emit,
  ) {
    AppLogger.logBloc(
      'ProfileBloc',
      'ResetProfileState',
      newState: 'ProfileInitial',
    );
    emit(ProfileInitial());
  }
}
