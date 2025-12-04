import 'api_error.dart';

/// Generic model class representing a JSON-RPC 2.0 response
class ApiResponse<T> {
  /// Protocol version (always '2.0')
  final String jsonrpc;

  /// Request ID for matching requests/responses
  final dynamic id;

  /// Success result data (generic type)
  final T? result;

  /// Error object if request failed
  final ApiError? error;

  /// Constructor with named parameters
  ApiResponse({
    required this.jsonrpc,
    required this.id,
    this.result,
    this.error,
  });

  /// Factory constructor that takes a JSON map and a function to parse the result type T
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? parseResult,
  ) {
    return ApiResponse<T>(
      jsonrpc: json['jsonrpc'] as String,
      id: json['id'],
      result: json['result'] != null && parseResult != null
          ? parseResult(json['result'])
          : json['result'] as T?,
      error: json['error'] != null
          ? ApiError.fromJson(json['error'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'jsonrpc': jsonrpc,
      'id': id,
      if (result != null) 'result': result,
      if (error != null) 'error': error?.toJson(),
    };
  }

  /// Returns true if the response is successful (no error)
  bool get isSuccess {
    return error == null;
  }

  /// Returns true if the response contains an error
  bool get isError {
    return error != null;
  }

  /// Returns result if successful, otherwise throws an exception with the error message
  T getResultOrThrow() {
    if (error != null) {
      throw Exception('API Error: ${error!.message} (code: ${error!.code})');
    }
    if (result == null) {
      throw Exception('API Error: No result returned');
    }
    return result as T;
  }

  @override
  String toString() {
    return 'ApiResponse(jsonrpc: $jsonrpc, id: $id, '
        '${isSuccess ? 'result: $result' : 'error: $error'})';
  }
}
