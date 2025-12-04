import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Login screen for GL.iNet router authentication
/// GL.iNet routers use 'root' as the username, so only password is needed
class LoginScreen extends StatefulWidget {
  final Future<bool> Function(String password) onLogin;
  final bool isLoading;

  const LoginScreen({
    super.key,
    required this.onLogin,
    this.isLoading = false,
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
                      _passwordObscured
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                    onPressed: () =>
                        setState(() => _passwordObscured = !_passwordObscured),
                    tooltip: _passwordObscured
                        ? l10n.showPassword
                        : l10n.hidePassword,
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
          ),
        ),
      ),
    );
  }
}
