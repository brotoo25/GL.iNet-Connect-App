import 'package:flutter/material.dart';
import '../services/glinet_api_service.dart';
import '../services/credential_storage_service.dart';
import '../models/exceptions.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'repeater_setup_screen.dart';

/// App shell that manages authentication state and routing
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final GlinetApiService _apiService;
  late final CredentialStorageService _storageService;

  // GL.iNet routers use 'root' as the default/only username
  static const String _defaultUsername = 'root';

  bool _isAuthenticated = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _apiService = GlinetApiService();
    _storageService = CredentialStorageService();
    _checkStoredCredentials();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  /// Check for stored credentials and attempt auto-login
  Future<void> _checkStoredCredentials() async {
    try {
      final hasCredentials = await _storageService.hasCredentials();
      if (hasCredentials) {
        final credential = await _storageService.getCredentials();
        if (credential != null) {
          await _performLogin(credential.password, saveToStorage: false);
        }
      }
    } on SessionExpiredException {
      // Silently fail - don't show error, just don't auto-login
    } on RouterUnreachableException {
      _showSnackBar(
        'Router unreachable. Please connect to the GL.iNet router network.',
        backgroundColor: Colors.orange,
      );
    } on AuthenticationException {
      await _storageService.deleteCredentials();
      _showSnackBar('Stored credentials are invalid. Please log in again.');
    } catch (e) {
      _showSnackBar('Auto-login failed. Please log in manually.');
    }
  }

  /// Perform login with given password
  Future<bool> _performLogin(String password,
      {bool saveToStorage = true}) async {
    setState(() => _isLoading = true);

    try {
      await _apiService.login(_defaultUsername, password);
      if (saveToStorage) {
        await _storageService.saveCredentials(_defaultUsername, password);
      }
      setState(() => _isAuthenticated = true);
      _showSnackBar('Login successful', backgroundColor: Colors.green);
      return true;
    } on RouterUnreachableException catch (e) {
      _showErrorDialog('Router Unreachable', e.message,
          canRetry: true,
          onRetry: () => _performLogin(password, saveToStorage: saveToStorage));
      return false;
    } on AuthenticationException catch (e) {
      _showErrorDialog('Authentication Failed', e.message);
      return false;
    } on SessionExpiredException catch (e) {
      _showErrorDialog('Authentication Failed', e.message);
      return false;
    } on NetworkException catch (e) {
      _showErrorDialog('Network Error', e.message,
          canRetry: true,
          onRetry: () => _performLogin(password, saveToStorage: saveToStorage));
      return false;
    } catch (e) {
      _showErrorDialog(
          'Login Failed', 'An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Handle logout with confirmation
  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Logout'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storageService.deleteCredentials();
      _apiService.logout();
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  /// Handle session expiration
  Future<void> _handleSessionExpired() async {
    _apiService.logout();
    await _storageService.deleteCredentials();
    setState(() {
      _isAuthenticated = false;
      _isLoading = false;
    });
    _showErrorDialog(
      'Session Expired',
      'Your session has expired. Please log in again to continue.',
    );
  }

  /// Navigate to repeater setup screen
  void _navigateToRepeaterSetup() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => RepeaterSetupScreen(
          apiService: _apiService,
          onSessionExpired: _handleSessionExpired,
        ),
      ),
    );
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            backgroundColor ?? Theme.of(context).colorScheme.inverseSurface,
      ),
    );
  }

  void _showErrorDialog(
    String title,
    String message, {
    bool canRetry = false,
    VoidCallback? onRetry,
  }) {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline,
                color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(message),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          if (canRetry && onRetry != null)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  onRetry();
                },
                child: const Text('Retry'),
              ),
            ),
          if (canRetry && onRetry != null) const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
      return DashboardScreen(
        onLogout: _handleLogout,
        onSetupRepeater: _navigateToRepeaterSetup,
        apiService: _apiService,
      );
    }

    return LoginScreen(
      onLogin: _performLogin,
      isLoading: _isLoading,
    );
  }
}
