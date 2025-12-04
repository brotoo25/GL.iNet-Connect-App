import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import '../models/api_response.dart';
import '../models/api_error.dart';
import '../models/wifi_network.dart';
import '../models/exceptions.dart';
import 'crypto_helper.dart';

/// Service class implementing JSON-RPC 2.0 client for GL.iNet router communication
class GlinetApiService {
  /// Router IP address
  static const String routerIp = '192.168.8.1';

  /// JSON-RPC endpoint URL
  static const String rpcEndpoint = 'http://192.168.8.1/rpc';

  /// Request timeout duration
  static const Duration requestTimeout = Duration(seconds: 30);

  /// HTTP client for making requests
  final http.Client _httpClient;

  /// Request ID counter for JSON-RPC
  int _requestId = 0;

  /// Current session ID (set after successful login)
  String? _sessionId;

  /// Constructor
  GlinetApiService()
      : _httpClient = RetryClient(
          http.Client(),
          retries: 3,
          when: (response) {
            // Retry on specific HTTP status codes
            return response.statusCode == 429 ||
                response.statusCode == 500 ||
                response.statusCode == 502 ||
                response.statusCode == 503;
          },
          whenError: (error, stackTrace) {
            // Retry on socket and timeout exceptions
            return error is SocketException || error is TimeoutException;
          },
          delay: (retryCount) {
            // Exponential backoff with jitter: 500ms, 1s, 2s
            final baseDelay =
                Duration(milliseconds: 500 * pow(2, retryCount).toInt());
            // Add jitter (±25%)
            final jitter = Random().nextInt(baseDelay.inMilliseconds ~/ 4);
            final jitterSign = Random().nextBool() ? 1 : -1;
            return Duration(
                milliseconds: baseDelay.inMilliseconds + (jitter * jitterSign));
          },
        );

  /// Get next request ID
  int _getNextRequestId() {
    return ++_requestId;
  }

  /// Make a JSON-RPC 2.0 request
  Future<ApiResponse<dynamic>> _makeRpcRequest(
    String method,
    dynamic params,
  ) async {
    try {
      // Build JSON-RPC 2.0 request
      final requestBody = {
        'jsonrpc': '2.0',
        'id': _getNextRequestId(),
        'method': method,
        'params': params,
      };

      // Make HTTP POST request
      final response = await _httpClient
          .post(
            Uri.parse(rpcEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(requestTimeout);

      // Check HTTP status
      if (response.statusCode != 200) {
        throw NetworkException(
            'HTTP ${response.statusCode} error: ${response.reasonPhrase ?? 'Unknown error'}');
      }

      // Parse JSON response
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      // Parse ApiResponse
      final apiResponse =
          ApiResponse<dynamic>.fromJson(jsonResponse, (result) => result);

      // Check for API errors and throw appropriate exceptions
      if (apiResponse.isError) {
        _handleApiError(apiResponse.error!, 'RPC request');
      }

      return apiResponse;
    } on TimeoutException {
      throw RouterUnreachableException(
          'Request timeout: Router did not respond within 30 seconds.');
    } on SocketException {
      throw RouterUnreachableException(
          'Cannot connect to router at $routerIp. Please ensure you are connected to the GL.iNet router network.');
    } on FormatException {
      throw NetworkException('Invalid response from router. Please try again.');
    } catch (e) {
      rethrow;
    }
  }

  /// Handle API errors and throw appropriate exceptions
  void _handleApiError(ApiError error, String context) {
    // Check for error code -32000 (access denied)
    if (error.code == -32000 &&
        error.message.toLowerCase().contains('access denied')) {
      // If we have a session ID, this means session expired
      // If we don't have a session ID, this means authentication failed
      if (_sessionId != null) {
        throw SessionExpiredException(
            'Your session has expired. Please log in again.', error);
      } else {
        throw AuthenticationException(
            'Authentication failed. Please check your username and password.',
            error);
      }
    }

    // Check for authentication errors
    if (error.isAuthenticationError) {
      throw AuthenticationException(
          'Authentication failed: ${error.message}', error);
    }

    // Check for timeout errors
    if (error.isTimeoutError) {
      throw RouterUnreachableException(
          'Request timed out: ${error.message}', error);
    }

    // Generic API error
    throw ApiException('API Error in $context: ${error.message}', error);
  }

  /// Make a JSON-RPC call (requires authentication)
  Future<ApiResponse<dynamic>> _makeRpcCall(
    String object,
    String function,
    Map<String, dynamic> params,
  ) async {
    if (_sessionId == null) {
      throw SessionExpiredException();
    }

    // Build params array: [sessionId, object, function, params]
    final callParams = [_sessionId, object, function, params];

    return _makeRpcRequest('call', callParams);
  }

  /// Perform challenge request to get salt and nonce
  Future<Map<String, dynamic>> challenge(String username) async {
    try {
      // GL.iNet API expects username in a map object like login
      final response =
          await _makeRpcRequest('challenge', {'username': username});

      final result = response.result as Map<String, dynamic>;

      // Validate required fields
      if (!result.containsKey('alg') ||
          !result.containsKey('salt') ||
          !result.containsKey('nonce')) {
        throw Exception('Invalid challenge response: missing required fields');
      }

      return result;
    } catch (e) {
      // Rethrow if already a custom exception
      if (e is ApiException) rethrow;
      throw AuthenticationException('Challenge request failed: $e');
    }
  }

  /// Login to the router with username and password
  Future<String> login(String username, String password) async {
    try {
      // Step 1: Get challenge (alg, salt, nonce, hash-method)
      final challengeData = await challenge(username);
      final algorithm = challengeData['alg'].toString();
      final salt = challengeData['salt'] as String;
      final nonce = challengeData['nonce'] as String;
      final hashMethod =
          (challengeData['hash-method'] as String?)?.toLowerCase() ?? 'md5';

      // Step 2: Compute Unix password hash
      final unixHash = CryptoHelper.computeUnixHash(password, salt, algorithm);

      // Step 3: Compute final login hash using indicated method
      final loginHash = CryptoHelper.computeLoginHashWithMethod(
          hashMethod, username, unixHash, nonce);

      // Step 4: Send login request
      final response = await _makeRpcRequest('login', {
        'username': username,
        'hash': loginHash,
      });

      final result = response.result as Map<String, dynamic>;

      // Extract session ID
      if (!result.containsKey('sid')) {
        throw Exception('Invalid login response: missing session ID');
      }

      _sessionId = result['sid'] as String;
      return _sessionId!;
    } on ArgumentError catch (e) {
      // Handle invalid parameters from CryptoHelper
      throw AuthenticationException('Invalid authentication parameters: $e');
    } catch (e) {
      // Rethrow if already a custom exception
      if (e is ApiException) rethrow;
      throw AuthenticationException('Login failed: $e');
    }
  }

  /// Scan for WiFi networks and return results (supports immediate and legacy behaviors)
  Future<List<WifiNetwork>> scanWifi({String band = 'auto'}) async {
    try {
      final response = await _makeRpcCall('repeater', 'scan', {'band': band});
      final result = response.result;

      // Some firmware returns results immediately in 'res' or 'list' or as a raw list
      List<dynamic>? networkList;
      if (result is Map<String, dynamic>) {
        if (result['res'] is List) {
          networkList = result['res'] as List<dynamic>;
        } else if (result['list'] is List) {
          networkList = result['list'] as List<dynamic>;
        }
      } else if (result is List) {
        networkList = result;
      }

      if (networkList != null && networkList.isNotEmpty) {
        final networks = <WifiNetwork>[];
        for (final item in networkList) {
          if (item is Map<String, dynamic>) {
            networks.add(WifiNetwork.fromJson(item));
          }
        }
        return networks;
      }

      // Fallback: older behavior where results are available via scan_results
      await Future<void>.delayed(const Duration(seconds: 3));
      final resultsResponse =
          await _makeRpcCall('repeater', 'scan_results', {});
      final res2 = resultsResponse.result;

      List<dynamic>? list2;
      if (res2 is Map<String, dynamic>) {
        if (res2['list'] is List) {
          list2 = res2['list'] as List<dynamic>;
        } else if (res2['res'] is List) {
          list2 = res2['res'] as List<dynamic>;
        }
      } else if (res2 is List) {
        list2 = res2;
      }

      if (list2 != null && list2.isNotEmpty) {
        final networks = <WifiNetwork>[];
        for (final item in list2) {
          if (item is Map<String, dynamic>) {
            networks.add(WifiNetwork.fromJson(item));
          }
        }
        return networks;
      }

      return <WifiNetwork>[];
    } catch (e) {
      // Map RouterUnreachableException to ScanException for scan context
      if (e is RouterUnreachableException) {
        throw ScanException('WiFi scan timed out. Please try again.');
      }
      // Rethrow if already a custom exception
      if (e is ApiException) rethrow;
      throw ScanException('Failed to scan WiFi networks: $e');
    }
  }

  /// Get WiFi scan results (legacy support)
  Future<List<WifiNetwork>> getScanResults() async {
    try {
      final response = await _makeRpcCall('repeater', 'scan_results', {});

      final result = response.result;

      // Support various result shapes: {list: [...]}, {res: [...]}, or a raw list
      List<dynamic>? networkList;
      if (result is Map<String, dynamic>) {
        if (result['list'] is List) {
          networkList = result['list'] as List<dynamic>;
        } else if (result['res'] is List) {
          networkList = result['res'] as List<dynamic>;
        }
      } else if (result is List) {
        networkList = result;
      }

      if (networkList == null || networkList.isEmpty) {
        return [];
      }

      final networks = <WifiNetwork>[];
      for (final item in networkList) {
        if (item is Map<String, dynamic>) {
          networks.add(WifiNetwork.fromJson(item));
        }
      }

      return networks;
    } catch (e) {
      // Map RouterUnreachableException to ScanException for scan context
      if (e is RouterUnreachableException) {
        throw ScanException('WiFi scan timed out. Please try again.');
      }
      // Rethrow if already a custom exception
      if (e is ApiException) rethrow;
      throw ScanException('Failed to retrieve scan results: $e');
    }
  }

  /// Connect to a WiFi network as repeater
  ///
  /// Uses the official GL.iNet API parameter names:
  /// - ssid: Network name (required)
  /// - key: WiFi password (required for encrypted networks)
  /// - bssid: Lock to specific access point (optional)
  /// - remember: Save network for auto-reconnect (optional, default false)
  Future<void> connectRepeater({
    required String ssid,
    required String password,
    String? bssid,
    String? encryption,
    bool remember = true,
  }) async {
    try {
      // Build params map using official GL.iNet API parameter names
      // Note: The API uses 'key' for password, not 'password'
      final params = <String, dynamic>{
        'ssid': ssid,
        'key': password, // Official API uses 'key' for WiFi password
        'remember': remember,
      };

      // Add optional bssid if provided (locks to specific access point)
      if (bssid != null && bssid.isNotEmpty) {
        params['bssid'] = bssid;
      }

      // Try modern 'connect' first; fallback to legacy 'join' if method not found
      try {
        await _makeRpcCall('repeater', 'connect', params);
      } on ApiException catch (ae) {
        final code = ae.apiError?.code;
        final msg = ae.apiError?.message.toLowerCase() ?? '';
        if (code == ApiError.methodNotFound ||
            msg.contains('method not found')) {
          await _makeRpcCall('repeater', 'join', params);
        } else {
          rethrow;
        }
      }
    } catch (e) {
      // Handle ApiException specifically to detect wrong password patterns
      if (e is ApiException) {
        // Check API error message for wrong password indicators
        final apiErrorMessage = e.apiError?.message.toLowerCase() ?? '';
        final exceptionMessage = e.message.toLowerCase();

        if (apiErrorMessage.contains('wrong key') ||
            apiErrorMessage.contains('invalid password') ||
            apiErrorMessage.contains('authentication') ||
            exceptionMessage.contains('wrong key') ||
            exceptionMessage.contains('invalid password') ||
            exceptionMessage.contains('authentication')) {
          throw RepeaterConnectionException(
              'Wrong WiFi password. Please check and try again.');
        }

        // Rethrow other ApiExceptions
        rethrow;
      }

      // Check for wrong password errors in generic exceptions
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('wrong key') ||
          errorMessage.contains('invalid password') ||
          errorMessage.contains('authentication')) {
        throw RepeaterConnectionException(
            'Wrong WiFi password. Please check and try again.');
      }

      throw RepeaterConnectionException(
          'Failed to connect to WiFi network: $e');
    }
  }

  /// Check the router's internet connectivity status
  ///
  /// Returns a map with connectivity information:
  /// - 'connected': bool - whether internet is available
  /// - 'pingResults': List<Map> - results of ping tests to various servers
  Future<Map<String, dynamic>> checkInternetStatus() async {
    final pingResults = <Map<String, dynamic>>[];

    // List of servers to check connectivity
    // Using DNS lookup to verify reachability (works for DNS servers)
    // and HTTP endpoints as backup
    final servers = [
      {
        'provider': 'Google',
        'ips': ['8.8.8.8', '8.8.4.4'],
        'testDomain': 'google.com',
      },
      {
        'provider': 'Cloudflare',
        'ips': ['1.1.1.1', '1.0.0.1'],
        'testDomain': 'cloudflare.com',
      },
    ];

    bool anySuccessful = false;

    for (final server in servers) {
      final provider = server['provider'] as String;
      final ips = server['ips'] as List<String>;
      final testDomain = server['testDomain'] as String;
      bool serverSuccess = false;

      // Method 1: Try DNS lookup to verify internet connectivity
      // This is more reliable than HTTP for checking if DNS servers are reachable
      try {
        final addresses = await InternetAddress.lookup(testDomain)
            .timeout(const Duration(seconds: 3));
        if (addresses.isNotEmpty) {
          serverSuccess = true;
          anySuccessful = true;
        }
      } on SocketException {
        // DNS lookup failed
      } on TimeoutException {
        // DNS lookup timed out
      } catch (e) {
        // Other error
      }

      // Method 2: If DNS lookup failed, try socket connection to the DNS server
      if (!serverSuccess) {
        for (final ip in ips) {
          try {
            // Try to open a socket connection to the DNS port (53)
            final socket = await Socket.connect(
              ip,
              53,
              timeout: const Duration(seconds: 2),
            );
            await socket.close();
            serverSuccess = true;
            anySuccessful = true;
            break; // One successful connection is enough
          } on SocketException {
            // Socket connection failed
          } on TimeoutException {
            // Socket connection timed out
          } catch (e) {
            // Other error
          }
        }
      }

      pingResults.add({
        'provider': provider,
        'ips': ips,
        'success': serverSuccess,
      });
    }

    return {
      'connected': anySuccessful,
      'pingResults': pingResults,
    };
  }

  /// Check if currently authenticated
  bool get isAuthenticated {
    return _sessionId != null;
  }

  /// Logout and clear session
  void logout() {
    _sessionId = null;
  }

  /// Dispose resources
  void dispose() {
    _httpClient.close();
  }
}
