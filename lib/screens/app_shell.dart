import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/glinet_api_service.dart';
import '../services/credential_storage_service.dart';
import '../services/wifi_info_service.dart';
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
  final WifiInfoService _wifiInfoService = WifiInfoService();

  // GL.iNet routers use 'root' as the default/only username
  static const String _defaultUsername = 'root';

  bool _isAuthenticated = false;
  bool _isLoading = false;
  RouterConnectionState _connectionState = RouterConnectionState.checking;

  @override
  void initState() {
    super.initState();
    _apiService = GlinetApiService();
    _storageService = CredentialStorageService();
    _initializeAndCheckConnection();
  }

  /// Initialize router IP and check if router is reachable
  Future<void> _initializeAndCheckConnection() async {
    setState(() => _connectionState = RouterConnectionState.checking);

    try {
      final gatewayIP = await _wifiInfoService.getWifiGatewayIP();
      if (gatewayIP != null && gatewayIP.isNotEmpty) {
        debugPrint('Detected gateway IP: $gatewayIP');
        _apiService.updateRouterIp(gatewayIP);
      } else {
        debugPrint(
            'Could not detect gateway IP, using default: ${GlinetApiService.defaultRouterIp}');
      }
    } catch (e) {
      debugPrint('Error detecting gateway IP: $e');
    }

    // Check if router is reachable
    final isReachable = await _apiService.isRouterReachable();
    debugPrint('Router reachable: $isReachable');

    if (!mounted) return;

    if (isReachable) {
      setState(() => _connectionState = RouterConnectionState.connected);
      // Only try auto-login if router is reachable
      _checkStoredCredentials();
    } else {
      setState(() => _connectionState = RouterConnectionState.notConnected);
    }
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  /// Check for stored credentials and attempt auto-login
  Future<void> _checkStoredCredentials() async {
    // Wait for the first frame to ensure context is available
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

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
        l10n.routerUnreachableMessage,
        backgroundColor: Colors.orange,
      );
    } on AuthenticationException {
      await _storageService.deleteCredentials();
      _showSnackBar(l10n.storedCredentialsInvalid);
    } catch (e) {
      _showSnackBar(l10n.autoLoginFailed);
    }
  }

  /// Perform login with given password
  Future<bool> _performLogin(String password,
      {bool saveToStorage = true}) async {
    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;

    try {
      await _apiService.login(_defaultUsername, password);
      if (saveToStorage) {
        await _storageService.saveCredentials(_defaultUsername, password);
      }
      setState(() => _isAuthenticated = true);
      _showSnackBar(l10n.loginSuccessful, backgroundColor: Colors.green);
      return true;
    } on RouterUnreachableException catch (e) {
      _showErrorDialog(l10n.routerUnreachable, e.message,
          canRetry: true,
          onRetry: () => _performLogin(password, saveToStorage: saveToStorage));
      return false;
    } on AuthenticationException catch (e) {
      _showErrorDialog(l10n.authenticationFailed, e.message);
      return false;
    } on SessionExpiredException catch (e) {
      _showErrorDialog(l10n.authenticationFailed, e.message);
      return false;
    } on NetworkException catch (e) {
      _showErrorDialog(l10n.networkError, e.message,
          canRetry: true,
          onRetry: () => _performLogin(password, saveToStorage: saveToStorage));
      return false;
    } catch (e) {
      _showErrorDialog(l10n.loginFailed, l10n.unexpectedError(e.toString()));
      return false;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Handle logout with confirmation
  Future<void> _handleLogout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirmation),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.logout),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
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
    final l10n = AppLocalizations.of(context)!;
    _apiService.logout();
    await _storageService.deleteCredentials();
    setState(() {
      _isAuthenticated = false;
      _isLoading = false;
    });
    _showErrorDialog(
      l10n.sessionExpired,
      l10n.sessionExpiredMessage,
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
    final l10n = AppLocalizations.of(context)!;
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
                child: Text(l10n.retry),
              ),
            ),
          if (canRetry && onRetry != null) const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.ok),
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
      onCheckConnection: _initializeAndCheckConnection,
      isLoading: _isLoading,
      connectionState: _connectionState,
    );
  }
}
