import 'package:flutter/foundation.dart';

/// Centralized logging system for the Todo BLoC application
class AppLogger {
  static const bool _isDebugMode = kDebugMode;
  static const String _appTag = '[TodoBLoC]';

  /// Log authentication operations
  static void logAuth(String operation, {Map<String, dynamic>? data, String? error}) {
    if (!_isDebugMode) return;
    
    final timestamp = DateTime.now().toIso8601String();
    final prefix = '$_appTag [AUTH] [$timestamp]';
    
    if (error != null) {
      debugPrint('$prefix ❌ $operation FAILED: $error');
    } else {
      debugPrint('$prefix ✅ $operation SUCCESS');
    }
    
    if (data != null) {
      debugPrint('$prefix 📊 Data: ${_formatData(data)}');
    }
    debugPrint('$prefix ─────────────────────────────────────');
  }

  /// Log Firestore operations
  static void logFirestore(String operation, String collection, {
    String? documentId,
    Map<String, dynamic>? data,
    String? error,
    int? resultCount,
  }) {
    if (!_isDebugMode) return;
    
    final timestamp = DateTime.now().toIso8601String();
    final prefix = '$_appTag [FIRESTORE] [$timestamp]';
    final path = documentId != null ? '$collection/$documentId' : collection;
    
    if (error != null) {
      debugPrint('$prefix ❌ $operation on $path FAILED: $error');
    } else {
      debugPrint('$prefix ✅ $operation on $path SUCCESS');
    }
    
    if (resultCount != null) {
      debugPrint('$prefix 📊 Result count: $resultCount');
    }
    
    if (data != null) {
      debugPrint('$prefix 📊 Data: ${_formatData(data)}');
    }
    debugPrint('$prefix ─────────────────────────────────────');
  }

  /// Log BLoC events and state changes
  static void logBloc(String blocName, String event, {
    String? previousState,
    String? newState,
    Map<String, dynamic>? eventData,
    String? error,
  }) {
    if (!_isDebugMode) return;
    
    final timestamp = DateTime.now().toIso8601String();
    final prefix = '$_appTag [BLOC] [$timestamp]';
    
    debugPrint('$prefix 🎯 $blocName received event: $event');
    
    if (eventData != null) {
      debugPrint('$prefix 📊 Event data: ${_formatData(eventData)}');
    }
    
    if (previousState != null && newState != null) {
      debugPrint('$prefix 🔄 State transition: $previousState → $newState');
    }
    
    if (error != null) {
      debugPrint('$prefix ❌ Error: $error');
    }
    
    debugPrint('$prefix ─────────────────────────────────────');
  }

  /// Log network operations
  static void logNetwork(String method, String url, {
    Map<String, dynamic>? requestData,
    Map<String, dynamic>? responseData,
    int? statusCode,
    String? error,
  }) {
    if (!_isDebugMode) return;
    
    final timestamp = DateTime.now().toIso8601String();
    final prefix = '$_appTag [NETWORK] [$timestamp]';
    
    if (error != null) {
      debugPrint('$prefix ❌ $method $url FAILED: $error');
    } else {
      debugPrint('$prefix ✅ $method $url SUCCESS (${statusCode ?? 'N/A'})');
    }
    
    if (requestData != null) {
      debugPrint('$prefix 📤 Request: ${_formatData(requestData)}');
    }
    
    if (responseData != null) {
      debugPrint('$prefix 📥 Response: ${_formatData(responseData)}');
    }
    
    debugPrint('$prefix ─────────────────────────────────────');
  }

  /// Log general application events
  static void logApp(String message, {
    String? category,
    Map<String, dynamic>? data,
    LogLevel level = LogLevel.info,
  }) {
    if (!_isDebugMode) return;
    
    final timestamp = DateTime.now().toIso8601String();
    final categoryTag = category != null ? '[$category]' : '';
    final prefix = '$_appTag [APP] $categoryTag [$timestamp]';
    final emoji = _getEmojiForLevel(level);
    
    debugPrint('$prefix $emoji $message');
    
    if (data != null) {
      debugPrint('$prefix 📊 Data: ${_formatData(data)}');
    }
    
    debugPrint('$prefix ─────────────────────────────────────');
  }

  /// Log user actions
  static void logUserAction(String action, {
    String? userId,
    Map<String, dynamic>? context,
  }) {
    if (!_isDebugMode) return;
    
    final timestamp = DateTime.now().toIso8601String();
    final prefix = '$_appTag [USER] [$timestamp]';
    final userInfo = userId != null ? ' (User: $userId)' : '';
    
    debugPrint('$prefix 👤 $action$userInfo');
    
    if (context != null) {
      debugPrint('$prefix 📊 Context: ${_formatData(context)}');
    }
    
    debugPrint('$prefix ─────────────────────────────────────');
  }

  /// Format data for logging
  static String _formatData(Map<String, dynamic> data) {
    if (data.isEmpty) return '{}';
    
    final buffer = StringBuffer();
    buffer.writeln('{');
    
    data.forEach((key, value) {
      final formattedValue = _formatValue(value);
      buffer.writeln('  $key: $formattedValue');
    });
    
    buffer.write('}');
    return buffer.toString();
  }

  /// Format individual values for logging
  static String _formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return '"$value"';
    if (value is DateTime) return value.toIso8601String();
    if (value is Map) return _formatData(value.cast<String, dynamic>());
    if (value is List) return '[${value.join(', ')}]';
    return value.toString();
  }

  /// Get emoji for log level
  static String _getEmojiForLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🐛';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
    }
  }
}

enum LogLevel {
  debug,
  info,
  warning,
  error,
}
