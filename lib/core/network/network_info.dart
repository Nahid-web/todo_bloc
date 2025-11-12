import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Abstract class for checking network connectivity
abstract class NetworkInfo {
  /// A getter to check if the device is currently connected to the internet.
  Future<bool> get isConnected;

  /// A stream that emits the internet connection status whenever it changes.
  Stream<InternetStatus> get onStatusChange;
}

/// Implementation of NetworkInfo using InternetConnection
class NetworkInfoImpl implements NetworkInfo {
  final InternetConnection _connectionChecker;

  NetworkInfoImpl(this._connectionChecker);

  @override
  Future<bool> get isConnected async {
    try {
      return await _connectionChecker.hasInternetAccess;
    } catch (_) {
      return false; // Or handle the error as appropriate for your app
    }
  }

  @override
  Stream<InternetStatus> get onStatusChange =>
      _connectionChecker.onStatusChange;
}
