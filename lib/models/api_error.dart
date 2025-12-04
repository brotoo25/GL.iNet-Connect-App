/// Model class representing a JSON-RPC error response
class ApiError {
  /// Common JSON-RPC error codes
  static const int methodNotFound = -32601;

  /// JSON-RPC error code
  final int code;

  /// Error message from the router
  final String message;

  /// Additional error data if provided
  final dynamic data;

  /// Constructor with named parameters
  ApiError({
    required this.code,
    required this.message,
    this.data,
  });

  /// Factory constructor to parse JSON-RPC error object
  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'],
    );
  }

  /// Returns true if the error indicates authentication failure
  bool get isAuthenticationError => message.toLowerCase().contains('auth');

  /// Returns true if the error indicates a timeout
  bool get isTimeoutError =>
      message.toLowerCase().contains('timeout') ||
      message.toLowerCase().contains('timed out');

  @override
  String toString() {
    return 'ApiError(code: $code, message: $message${data != null ? ', data: $data' : ''})';
  }
}
