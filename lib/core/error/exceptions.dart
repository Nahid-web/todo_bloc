/// Base exception class for the application
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when a server call fails
class ServerException extends AppException {
  const ServerException(super.message, {super.code});

  @override
  String toString() => 'ServerException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when a cache operation fails
class CacheException extends AppException {
  const CacheException(super.message, {super.code});

  @override
  String toString() => 'CacheException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when network is not available
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});

  @override
  String toString() => 'NetworkException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when authentication fails
class AuthException extends AppException {
  const AuthException(super.message, {super.code});

  @override
  String toString() => 'AuthException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});

  @override
  String toString() => 'ValidationException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when a resource is not found
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.code});

  @override
  String toString() => 'NotFoundException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when access is forbidden
class ForbiddenException extends AppException {
  const ForbiddenException(super.message, {super.code});

  @override
  String toString() => 'ForbiddenException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when a timeout occurs
class TimeoutException extends AppException {
  const TimeoutException(super.message, {super.code});

  @override
  String toString() => 'TimeoutException: $message${code != null ? ' (Code: $code)' : ''}';
}
