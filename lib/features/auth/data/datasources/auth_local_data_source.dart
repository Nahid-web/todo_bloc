import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/logging/app_logger.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearCachedUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _cachedUserKey = 'CACHED_USER';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserModel?> getCachedUser() async {
    AppLogger.logApp(
      'Getting cached user from local storage',
      category: 'LOCAL_STORAGE',
    );

    try {
      final jsonString = sharedPreferences.getString(_cachedUserKey);
      
      if (jsonString == null) {
        AppLogger.logApp(
          'No cached user found in local storage',
          category: 'LOCAL_STORAGE',
        );
        return null;
      }

      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      final userModel = UserModel.fromJson(jsonMap);
      
      AppLogger.logApp(
        'Cached user retrieved from local storage',
        category: 'LOCAL_STORAGE',
        data: {
          'userId': userModel.id,
          'email': userModel.email,
          'isAnonymous': userModel.isAnonymous,
        },
      );

      return userModel;
    } catch (e) {
      AppLogger.logApp(
        'Failed to get cached user from local storage',
        category: 'LOCAL_STORAGE',
        data: {'error': e.toString()},
        level: LogLevel.error,
      );
      return null;
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    AppLogger.logApp(
      'Caching user to local storage',
      category: 'LOCAL_STORAGE',
      data: {
        'userId': user.id,
        'email': user.email,
        'isAnonymous': user.isAnonymous,
      },
    );

    try {
      final jsonString = json.encode(user.toJson());
      await sharedPreferences.setString(_cachedUserKey, jsonString);
      
      AppLogger.logApp(
        'User cached to local storage successfully',
        category: 'LOCAL_STORAGE',
      );
    } catch (e) {
      AppLogger.logApp(
        'Failed to cache user to local storage',
        category: 'LOCAL_STORAGE',
        data: {'error': e.toString()},
        level: LogLevel.error,
      );
      rethrow;
    }
  }

  @override
  Future<void> clearCachedUser() async {
    AppLogger.logApp(
      'Clearing cached user from local storage',
      category: 'LOCAL_STORAGE',
    );

    try {
      await sharedPreferences.remove(_cachedUserKey);
      
      AppLogger.logApp(
        'Cached user cleared from local storage successfully',
        category: 'LOCAL_STORAGE',
      );
    } catch (e) {
      AppLogger.logApp(
        'Failed to clear cached user from local storage',
        category: 'LOCAL_STORAGE',
        data: {'error': e.toString()},
        level: LogLevel.error,
      );
      rethrow;
    }
  }
}
