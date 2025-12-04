import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/credential.dart';

/// Service class for secure credential storage using flutter_secure_storage
///
/// This service provides secure storage for router admin credentials with
/// platform-specific encryption:
/// - Android: Uses EncryptedSharedPreferences with AES-GCM encryption
/// - iOS: Uses Keychain with first_unlock accessibility
class CredentialStorageService {
  /// Storage key for username
  static const String _keyUsername = 'router_admin_username';

  /// Storage key for password
  static const String _keyPassword = 'router_admin_password';

  /// Instance of secure storage with platform-specific options
  late final FlutterSecureStorage _storage;

  CredentialStorageService() {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        // Use EncryptedSharedPreferences for API 23+
        encryptedSharedPreferences: true,
        // Custom preferences name for organization
        sharedPreferencesName: 'glinet_secure_prefs',
        // Key prefix for organization
        preferencesKeyPrefix: 'glinet_',
        // Strong encryption algorithm
        storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
      ),
      iOptions: IOSOptions(
        // Available after first device unlock
        accessibility: KeychainAccessibility.first_unlock,
        // Keychain account identifier
        accountName: 'glinet_repeater_app',
        // Don't sync to iCloud for security
        synchronizable: false,
      ),
    );
  }

  /// Securely stores router admin credentials for auto-login
  ///
  /// Throws [ArgumentError] if username or password is empty
  /// Throws [Exception] if storage operation fails
  Future<void> saveCredentials(String username, String password) async {
    // Validate inputs
    if (username.isEmpty) {
      throw ArgumentError('Username cannot be empty');
    }
    if (password.isEmpty) {
      throw ArgumentError('Password cannot be empty');
    }

    try {
      // Store username
      await _storage.write(key: _keyUsername, value: username);
      // Store password
      await _storage.write(key: _keyPassword, value: password);
    } on PlatformException catch (e) {
      debugPrint('Failed to save credentials: ${e.message}');
      throw Exception('Failed to save credentials: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error saving credentials: $e');
      throw Exception('Failed to save credentials: $e');
    }
  }

  /// Retrieves stored router admin credentials
  ///
  /// Returns [Credential] instance if credentials exist, null otherwise
  /// Returns null on any error (graceful degradation)
  Future<Credential?> getCredentials() async {
    try {
      // Retrieve username
      final username = await _storage.read(key: _keyUsername);
      // Retrieve password
      final password = await _storage.read(key: _keyPassword);

      // Return credential if both exist
      if (username != null && password != null) {
        return Credential(username: username, password: password);
      }

      return null;
    } on PlatformException catch (e) {
      debugPrint('Failed to retrieve credentials: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Unexpected error retrieving credentials: $e');
      return null;
    }
  }

  /// Checks if credentials are stored without reading them
  ///
  /// Returns true if both username and password are stored, false otherwise
  /// Returns false on any error
  Future<bool> hasCredentials() async {
    try {
      // Check if username exists
      final hasUsername = await _storage.containsKey(key: _keyUsername);
      // Check if password exists
      final hasPassword = await _storage.containsKey(key: _keyPassword);

      // Return true only if both exist
      return hasUsername && hasPassword;
    } on PlatformException catch (e) {
      debugPrint('Failed to check credentials: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Unexpected error checking credentials: $e');
      return false;
    }
  }

  /// Clears stored credentials (used for logout)
  Future<void> deleteCredentials() async {
    try {
      await _storage.delete(key: _keyUsername);
      await _storage.delete(key: _keyPassword);
    } on PlatformException catch (e) {
      debugPrint('Failed to delete credentials: ${e.message}');
      throw Exception('Failed to delete credentials: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error deleting credentials: $e');
      throw Exception('Failed to delete credentials: $e');
    }
  }
}
