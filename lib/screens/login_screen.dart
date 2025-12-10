import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';

/// Connection state for the login screen
enum RouterConnectionState {
  /// Currently checking if router is reachable
  checking,

  /// Router is reachable, show login form
  connected,

  /// Router is not reachable, show error message
  notConnected,
}

/// Login screen for GL.iNet router authentication
/// GL.iNet routers use 'root' as the username, so only password is needed
class LoginScreen extends StatefulWidget {
  final Future<bool> Function(String password) onLogin;
  final VoidCallback onCheckConnection;
  final bool isLoading;
  final RouterConnectionState connectionState;

  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onCheckConnection,
    this.isLoading = false,
    this.connectionState = RouterConnectionState.checking,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _passwordController;
  bool _passwordObscured = true;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (widget.isLoading) return;
    final l10n = AppLocalizations.of(context)!;

    final password = _passwordController.text;
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterPassword)),
      );
      return;
    }

    final success = await widget.onLogin(password);
    if (success && mounted) {
      _passwordController.clear();
    }
  }

  Future<void> _openWifiSettings() async {
    // On iOS, we can only open the app settings, not WiFi settings directly
    // On Android, we can open WiFi settings directly
    final Uri url;
    if (Platform.isAndroid) {
      url = Uri.parse('android.settings.WIFI_SETTINGS');
    } else {
      // iOS: Open the Settings app (WiFi settings can't be opened directly)
      url = Uri.parse('App-Prefs:WIFI');
    }

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        // Fallback: try opening general settings
        final fallbackUrl = Uri.parse('app-settings:');
        if (await canLaunchUrl(fallbackUrl)) {
          await launchUrl(fallbackUrl);
        }
      }
    } catch (e) {
      debugPrint('Could not open WiFi settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),
              // Logo
              Center(
                child: Image.asset(
                  'assets/logo_white.png',
                  width: 100,
                  height: 100,
                ),
              ),
              const SizedBox(height: 32),
              // Show different content based on connection state
              if (widget.connectionState == RouterConnectionState.checking)
                _buildCheckingState(theme, l10n)
              else if (widget.connectionState ==
                  RouterConnectionState.notConnected)
                _buildNotConnectedState(theme, l10n)
              else
                _buildLoginForm(theme, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckingState(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        Text(
          l10n.checkingRouterConnection,
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        const CircularProgressIndicator(),
      ],
    );
  }

  Widget _buildNotConnectedState(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        Icon(
          Icons.wifi_off_rounded,
          size: 64,
          color: theme.colorScheme.error,
        ),
        const SizedBox(height: 24),
        Text(
          l10n.notConnectedToRouter,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            l10n.notConnectedToRouterMessage,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 40),
        FilledButton.icon(
          onPressed: _openWifiSettings,
          icon: const Icon(Icons.wifi),
          label: Text(l10n.openWifiSettings),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: widget.onCheckConnection,
          icon: const Icon(Icons.refresh),
          label: Text(l10n.checkConnection),
        ),
      ],
    );
  }

  Widget _buildLoginForm(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        Text(
          l10n.loginTitle,
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        // Subtitle
        Text(
          l10n.loginSubtitle,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        // Admin Password label
        Text(
          l10n.adminPassword,
          style: theme.textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        // Password field
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            hintText: l10n.passwordHint,
            suffixIcon: IconButton(
              icon: Icon(
                _passwordObscured ? Icons.visibility_off : Icons.visibility,
                color: theme.textTheme.bodyMedium?.color,
              ),
              onPressed: () =>
                  setState(() => _passwordObscured = !_passwordObscured),
              tooltip:
                  _passwordObscured ? l10n.showPassword : l10n.hidePassword,
            ),
          ),
          obscureText: _passwordObscured,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleLogin(),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 24),
        // Login button
        FilledButton(
          onPressed: widget.isLoading ? null : _handleLogin,
          child: widget.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(l10n.login),
        ),
      ],
    );
  }
}
