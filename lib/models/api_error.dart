/// Model class representing a JSON-RPC error response
class ApiError {
  /// Common JSON-RPC error codes
  static const int invalidRequest = -32600;
  static const int methodNotFound = -32601;
  static const int invalidParams = -32602;
  static const int internalError = -32603;
  static const int parseError = -32700;
  static const int authenticationError = -32002;

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

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      if (data != null) 'data': data,
    };
  }

  /// Returns true if the error indicates authentication failure
  bool get isAuthenticationError {
    return code == authenticationError ||
        message.toLowerCase().contains('auth');
  }

  /// Returns true if the error indicates a timeout
  bool get isTimeoutError {
    return message.toLowerCase().contains('timeout') ||
        message.toLowerCase().contains('timed out');
  }

  @override
  String toString() {
    return 'ApiError(code: $code, message: $message${data != null ? ', data: $data' : ''})';
  }
}

