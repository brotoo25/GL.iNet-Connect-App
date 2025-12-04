import 'api_error.dart';

/// Base exception class for all API-related exceptions.
///
/// This class provides a foundation for more specific exception types,
/// allowing for better error handling and context preservation throughout
/// the application.
class ApiException implements Exception {
  /// Human-readable error message
  final String message;

  /// Optional API error details from the server response
  final ApiError? apiError;

  /// Creates an API exception with the given message and optional API error details
  ApiException(this.message, [this.apiError]);

  @override
  String toString() {
    if (apiError != null) {
      return 'ApiException: $message (Error code: ${apiError!.code})';
    }
    return 'ApiException: $message';
  }
}

/// Exception thrown when the router cannot be reached.
///
/// This typically occurs when:
/// - The device is not connected to the GL.iNet router network
/// - The router is powered off or unreachable
/// - Network timeout occurs
/// - Socket connection fails
///
/// **User Action:** Check connection to the GL.iNet router (192.168.8.1)
/// and ensure the router is powered on and accessible.
class RouterUnreachableException extends ApiException {
  RouterUnreachableException([
    String? message,
    ApiError? apiError,
  ]) : super(
          message ??
              'Router is unreachable. Please check your connection to the GL.iNet router (192.168.8.1).',
          apiError,
        );
}

/// Exception thrown when authentication fails.
///
/// This occurs when:
/// - Invalid username or password is provided
/// - Challenge request fails
/// - Login credentials are rejected by the router
///
/// **User Action:** Verify username and password are correct and try again.
class AuthenticationException extends ApiException {
  AuthenticationException([
    String? message,
    ApiError? apiError,
  ]) : super(
          message ??
              'Authentication failed. Please check your username and password.',
          apiError,
        );
}

/// Exception thrown when the session expires during operations.
///
/// This occurs when:
/// - The router session times out (typically after inactivity)
/// - API returns error code -32000 with "Access denied" message
/// - Session ID becomes invalid
///
/// **User Action:** Log in again to establish a new session.
class SessionExpiredException extends ApiException {
  SessionExpiredException([
    String? message,
    ApiError? apiError,
  ]) : super(
          message ?? 'Your session has expired. Please log in again.',
          apiError,
        );
}

/// Exception thrown when repeater connection to a WiFi network fails.
///
/// This occurs when:
/// - Wrong WiFi password is provided
/// - WiFi network is out of range
/// - Repeater configuration fails
/// - Network authentication fails
///
/// **User Action:** Check the WiFi password and ensure the network is in range.
class RepeaterConnectionException extends ApiException {
  RepeaterConnectionException([
    String? message,
    ApiError? apiError,
  ]) : super(
          message ??
              'Failed to connect to the WiFi network. Please check the password and try again.',
          apiError,
        );
}

/// Exception thrown when WiFi scanning fails.
///
/// This occurs when:
/// - Scan initiation fails (repeater.scan)
/// - Scan results retrieval fails (repeater.scan_results)
/// - Router WiFi hardware is unavailable
///
/// **User Action:** Try scanning again. If the problem persists, restart the router.
class ScanException extends ApiException {
  ScanException([
    String? message,
    ApiError? apiError,
  ]) : super(
          message ?? 'WiFi scan failed. Please try again.',
          apiError,
        );
}

/// Exception thrown for general network errors.
///
/// This occurs when:
/// - HTTP request fails with unexpected status code
/// - Response format is invalid
/// - Network connectivity issues occur
/// - Unexpected network-related errors
///
/// **User Action:** Check network connection and try again.
class NetworkException extends ApiException {
  NetworkException([
    String? message,
    ApiError? apiError,
  ]) : super(
          message ?? 'Network error occurred. Please check your connection.',
          apiError,
        );
}

