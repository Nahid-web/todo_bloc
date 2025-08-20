import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/logging/app_logger.dart';
import '../models/user_profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<UserProfileModel?> getCachedUserProfile(String userId);
  Future<void> cacheUserProfile(UserProfileModel profile);
  Future<void> clearCachedUserProfile(String userId);
  Future<Map<String, dynamic>> getUserPreferences(String userId);
  Future<void> saveUserPreferences(String userId, Map<String, dynamic> preferences);
  Future<Map<String, dynamic>> getUserSettings(String userId);
  Future<void> saveUserSettings(String userId, Map<String, dynamic> settings);
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final SharedPreferences sharedPreferences;

  ProfileLocalDataSourceImpl({required this.sharedPreferences});

  static const String _profilePrefix = 'cached_profile_';
  static const String _preferencesPrefix = 'user_preferences_';
  static const String _settingsPrefix = 'user_settings_';

  @override
  Future<UserProfileModel?> getCachedUserProfile(String userId) async {
    try {
      AppLogger.logApp(
        'Getting cached user profile',
        category: 'LOCAL_STORAGE',
        data: {'userId': userId},
      );

      final jsonString = sharedPreferences.getString('$_profilePrefix$userId');
      if (jsonString != null) {
        final profile = UserProfileModel.fromJson(json.decode(jsonString));
        
        AppLogger.logApp(
          'Cached user profile found',
          category: 'LOCAL_STORAGE',
          data: {
            'userId': profile.id,
            'email': profile.email,
            'displayName': profile.displayName,
          },
        );
        
        return profile;
      }

      AppLogger.logApp(
        'No cached user profile found',
        category: 'LOCAL_STORAGE',
        data: {'userId': userId},
      );

      return null;
    } catch (e) {
      AppLogger.logApp(
        'Failed to get cached user profile',
        category: 'LOCAL_STORAGE',
        data: {'userId': userId},
        error: e.toString(),
        level: LogLevel.error,
      );
      throw CacheException('Failed to get cached user profile: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheUserProfile(UserProfileModel profile) async {
    try {
      AppLogger.logApp(
        'Caching user profile',
        category: 'LOCAL_STORAGE',
        data: {
          'userId': profile.id,
          'email': profile.email,
          'displayName': profile.displayName,
        },
      );

      final jsonString = json.encode(profile.toJson());
      await sharedPreferences.setString('$_profilePrefix${profile.id}', jsonString);

      AppLogger.logApp(
        'User profile cached successfully',
        category: 'LOCAL_STORAGE',
        data: {'userId': profile.id},
      );
    } catch (e) {
      AppLogger.logApp(
        'Failed to cache user profile',
        category: 'LOCAL_STORAGE',
        data: {'userId': profile.id},
        error: e.toString(),
        level: LogLevel.error,
      );
      throw CacheException('Failed to cache user profile: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCachedUserProfile(String userId) async {
    try {
      AppLogger.logApp(
        'Clearing cached user profile',
        category: 'LOCAL_STORAGE',
        data: {'userId': userId},
      );

      await sharedPreferences.remove('$_profilePrefix$userId');
      await sharedPreferences.remove('$_preferencesPrefix$userId');
      await sharedPreferences.remove('$_settingsPrefix$userId');

      AppLogger.logApp(
        'Cached user profile cleared successfully',
        category: 'LOCAL_STORAGE',
        data: {'userId': userId},
      );
    } catch (e) {
      AppLogger.logApp(
        'Failed to clear cached user profile',
        category: 'LOCAL_STORAGE',
        data: {'userId': userId},
        error: e.toString(),
        level: LogLevel.error,
      );
      throw CacheException('Failed to clear cached user profile: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserPreferences(String userId) async {
    try {
      AppLogger.logApp(
        'Getting user preferences',
        category: 'LOCAL_STORAGE',
        data: {'userId': userId},
      );

      final jsonString = sharedPreferences.getString('$_preferencesPrefix$userId');
      if (jsonString != null) {
        final preferences = Map<String, dynamic>.from(json.decode(jsonString));
        
        AppLogger.logApp(
          'User preferences found',
          category: 'LOCAL_STORAGE',
          data: {
            'userId': userId,
            'preferencesCount': preferences.length,
          },
        );
        
        return preferences;
      }

      // Return default preferences
      final defaultPreferences = <String, dynamic>{
        'defaultCategory': 'personal',
        'defaultPriority': 'medium',
        'showCompletedTodos': true,
        'enableNotifications': true,
        'notificationTime': '09:00',
      };

      AppLogger.logApp(
        'No user preferences found, returning defaults',
        category: 'LOCAL_STORAGE',
        data: {'userId': userId},
      );

      return defaultPreferences;
    } catch (e) {
      AppLogger.logApp(
        'Failed to get user preferences',
        category: 'LOCAL_STORAGE',
        data: {'userId': userId},
        error: e.toString(),
        level: LogLevel.error,
      );
      throw CacheException('Failed to get user preferences: ${e.toString()}');
    }
  }

  @override
  Future<void> saveUserPreferences(String userId, Map<String, dynamic> preferences) async {
    try {
      AppLogger.logApp(
        'Saving user preferences',
        category: 'LOCAL_STORAGE',
        data: {
          'userId': userId,
          'preferencesCount': preferences.length,
        },
      );

      final jsonString = json.encode(preferences);
      await sharedPreferences.setString('$_preferencesPrefix$userId', jsonString);

      AppLogger.logApp(
        'User preferences saved successfully',
        category: 'LOCAL_STORAGE',
        data: {'userId': userId},
      );
    } catch (e) {
      AppLogger.logApp(
        'Failed to save user preferences',
        category: 'LOCAL_STORAGE',
        data: {'userId': userId},
        error: e.toString(),
        level: LogLevel.error,
      );
      throw CacheException('Failed to save user preferences: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserSettings(String userId) async {
    try {
      AppLogger.logApp(
        'Getting user settings',
        category: 'LOCAL_STORAGE',
        data: {'userId': userId},
      );

      final jsonString = sharedPreferences.getString('$_settingsPrefix$userId');
      if (jsonString != null) {
        final settings = Map<String, dynamic>.from(json.decode(jsonString));
        
        AppLogger.logApp(
          'User settings found',
          category: 'LOCAL_STORAGE',
          data: {
            'userId': userId,
            'settingsCount': settings.length,
          },
        );
        
        return settings;
      }

      // Return default settings
      final defaultSettings = <String, dynamic>{
        'theme': 'system',
        'language': 'en',
        'dateFormat': 'MMM dd, yyyy',
        'timeFormat': '24h',
        'autoSync': true,
        'offlineMode': false,
      };

      AppLogger.logApp(
        'No user settings found, returning defaults',
        category: 'LOCAL_STORAGE',
        data: {'userId': userId},
      );

      return defaultSettings;
    } catch (e) {
      AppLogger.logApp(
        'Failed to get user settings',
        category: 'LOCAL_STORAGE',
        data: {'userId': userId},
        error: e.toString(),
        level: LogLevel.error,
      );
      throw CacheException('Failed to get user settings: ${e.toString()}');
    }
  }

  @override
  Future<void> saveUserSettings(String userId, Map<String, dynamic> settings) async {
    try {
      AppLogger.logApp(
        'Saving user settings',
        category: 'LOCAL_STORAGE',
        data: {
          'userId': userId,
          'settingsCount': settings.length,
        },
      );

      final jsonString = json.encode(settings);
      await sharedPreferences.setString('$_settingsPrefix$userId', jsonString);

      AppLogger.logApp(
        'User settings saved successfully',
        category: 'LOCAL_STORAGE',
        data: {'userId': userId},
      );
    } catch (e) {
      AppLogger.logApp(
        'Failed to save user settings',
        category: 'LOCAL_STORAGE',
        data: {'userId': userId},
        error: e.toString(),
        level: LogLevel.error,
      );
      throw CacheException('Failed to save user settings: ${e.toString()}');
    }
  }
}
