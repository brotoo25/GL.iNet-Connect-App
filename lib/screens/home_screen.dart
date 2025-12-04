import 'package:flutter/material.dart';
import '../services/glinet_api_service.dart';
import '../services/credential_storage_service.dart';
import '../models/wifi_network.dart';
import '../models/exceptions.dart';
import 'dashboard_screen.dart';

/// Main screen for GL.iNet repeater setup application
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Service instances
  late final GlinetApiService _apiService;
  late final CredentialStorageService _storageService;

  // GL.iNet routers use 'root' as the default/only username
  // This matches the web interface behavior where only password is required
  static const String _defaultUsername = 'root';

  // State variables
  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _isScanning = false;
  List<WifiNetwork> _networks = [];

  // Text controllers - only password needed (username is always 'root')
  late final TextEditingController _passwordController;
  bool _passwordObscured = true;

  @override
  void initState() {
    super.initState();
    _apiService = GlinetApiService();
    _storageService = CredentialStorageService();
    _passwordController = TextEditingController();
    _checkStoredCredentials();
  }

  @override
  void dispose() {
    _passwordController.dispose();
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
          await _performLogin(credential.username, credential.password,
              saveToStorage: false);
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

  /// Perform login with given credentials
  Future<bool> _performLogin(
    String username,
    String password, {
    bool saveToStorage = true,
  }) async {
    setState(() => _isLoading = true);

    try {
      await _apiService.login(username, password);
      if (saveToStorage) {
        await _storageService.saveCredentials(username, password);
      }
      setState(() => _isAuthenticated = true);
      _showSnackBar('Login successful', backgroundColor: Colors.green);
      return true;
    } on RouterUnreachableException catch (e) {
      _showErrorDialog(
        'Router Unreachable',
        e.message,
        canRetry: true,
        onRetry: () =>
            _performLogin(username, password, saveToStorage: saveToStorage),
      );
      return false;
    } on AuthenticationException catch (e) {
      _showErrorDialog('Authentication Failed', e.message);
      return false;
    } on SessionExpiredException catch (e) {
      _showErrorDialog('Authentication Failed', e.message);
      return false;
    } on NetworkException catch (e) {
      _showErrorDialog(
        'Network Error',
        e.message,
        canRetry: true,
        onRetry: () =>
            _performLogin(username, password, saveToStorage: saveToStorage),
      );
      return false;
    } catch (e) {
      _showErrorDialog(
          'Login Failed', 'An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Handle login button press
  Future<void> _handleLogin() async {
    if (_isLoading) return;

    final password = _passwordController.text;

    if (password.isEmpty) {
      _showSnackBar('Please enter the admin password');
      return;
    }

    await _performLogin(_defaultUsername, password, saveToStorage: true);
    _passwordController.clear();
  }

  /// Handle logout with confirmation
  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
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
        _isScanning = false;
        _networks.clear();
      });
      _passwordController.clear();
      _showSnackBar('Logged out successfully');
    }
  }

  /// Handle WiFi network scanning
  Future<void> _handleScanNetworks() async {
    if (_isScanning || _isLoading) return;

    setState(() => _isScanning = true);

    try {
      final networks = await _apiService.scanWifi();

      // Sort by signal strength (strongest first)
      networks.sort((a, b) => b.signal.compareTo(a.signal));

      setState(() => _networks = networks);

      if (networks.isEmpty) {
        _showSnackBar(
          'No WiFi networks found. Make sure WiFi is enabled on nearby devices.',
          backgroundColor: Colors.blue,
        );
      } else {
        _showSnackBar(
          'Found ${networks.length} network(s)',
          backgroundColor: Colors.blue,
        );
      }
    } on SessionExpiredException {
      await _handleSessionExpired();
    } on ScanException catch (e) {
      _showErrorDialog(
        'Scan Failed',
        e.message,
        canRetry: true,
        onRetry: _handleScanNetworks,
      );
    } on NetworkException catch (e) {
      _showErrorDialog(
        'Network Error',
        e.message,
        canRetry: true,
        onRetry: _handleScanNetworks,
      );
    } catch (e) {
      _showSnackBar('Scan failed: ${e.toString()}');
    } finally {
      setState(() => _isScanning = false);
    }
  }

  /// Handle network selection and show password dialog
  Future<void> _handleNetworkSelection(WifiNetwork network) async {
    // Guard against concurrent operations
    if (_isLoading || _isScanning) return;

    final passwordController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Connect to ${network.ssid}'),
        content: TextField(
          controller: passwordController,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => Navigator.pop(context, true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Connect'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final password = passwordController.text;
      setState(() => _isLoading = true);

      try {
        await _apiService.connectRepeater(
          ssid: network.ssid,
          password: password,
          bssid: network.bssid,
        );
        _showSnackBar('Connected to ${network.ssid}',
            backgroundColor: Colors.green);
      } on SessionExpiredException {
        await _handleSessionExpired();
      } on RepeaterConnectionException catch (e) {
        _showErrorDialog('Connection Failed', e.message);
      } on RouterUnreachableException catch (e) {
        _showErrorDialog(
          'Router Unreachable',
          e.message,
          canRetry: true,
          onRetry: () => _handleNetworkSelection(network),
        );
      } on NetworkException catch (e) {
        _showErrorDialog(
          'Network Error',
          e.message,
          canRetry: true,
          onRetry: () => _handleNetworkSelection(network),
        );
      } catch (e) {
        _showErrorDialog(
            'Connection Failed', 'Failed to connect: ${e.toString()}');
      } finally {
        setState(() => _isLoading = false);
      }
    }

    passwordController.dispose();
  }

  /// Show snackbar with message
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

  /// Show error dialog with optional retry
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
              child: Text(
                title,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(message),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          if (canRetry && onRetry != null)
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  /// Handle session expiration
  Future<void> _handleSessionExpired() async {
    _apiService.logout();
    await _storageService.deleteCredentials();
    setState(() {
      _isAuthenticated = false;
      _isLoading = false;
      _isScanning = false;
      _networks.clear();
    });
    _passwordController.clear();
    _showErrorDialog(
      'Session Expired',
      'Your session has expired. Please log in again to continue.',
    );
  }

  /// Get WiFi icon based on signal strength
  IconData _getSignalIcon(String strength) {
    switch (strength) {
      case 'Excellent':
        return Icons.network_wifi;
      case 'Good':
        return Icons.network_wifi;
      case 'Fair':
        return Icons.network_wifi_2_bar;
      case 'Weak':
        return Icons.network_wifi_1_bar;
      default:
        return Icons.wifi_off;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show dashboard after authentication, otherwise show login form
    if (_isAuthenticated) {
      return DashboardScreen(
        onLogout: _handleLogout,
        onSetupRepeater: _navigateToRepeaterSetup,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('GL.iNet Repeater Setup'),
      ),
      body: _buildLoginForm(),
    );
  }

  /// Navigate to repeater setup (WiFi scanning interface)
  void _navigateToRepeaterSetup() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Set Up Wi-Fi Repeater'),
          ),
          body: _buildMainInterface(),
        ),
      ),
    );
  }

  /// Build login form UI
  /// GL.iNet routers use 'root' as the username, so only password is needed
  Widget _buildLoginForm() {
    final theme = Theme.of(context);

    return SafeArea(
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
              'Router Login',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Subtitle
            Text(
              "Enter your router's admin password.",
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Admin Password label
            Text(
              'Admin Password',
              style: theme.textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            // Password field
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordObscured ? Icons.visibility_off : Icons.visibility,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  onPressed: () =>
                      setState(() => _passwordObscured = !_passwordObscured),
                  tooltip:
                      _passwordObscured ? 'Show password' : 'Hide password',
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
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build main interface UI (after authentication)
  Widget _buildMainInterface() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Scan for WiFi networks and select one to configure as repeater',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: FilledButton.icon(
            onPressed: (_isScanning || _isLoading) ? null : _handleScanNetworks,
            icon: const Icon(Icons.wifi),
            label: const Text('Scan Networks'),
          ),
        ),
        if (_isScanning) ...[
          const SizedBox(height: 16),
          const LinearProgressIndicator(),
          const SizedBox(height: 8),
          const Text('Scanning...'),
        ],
        const SizedBox(height: 16),
        Expanded(
          child: _networks.isEmpty
              ? const Center(
                  child: Text('No networks found. Tap Scan Networks to start.'),
                )
              : _buildNetworkList(),
        ),
      ],
    );
  }

  /// Build network list UI
  Widget _buildNetworkList() {
    return IgnorePointer(
      ignoring: _isLoading,
      child: ListView.separated(
        itemCount: _networks.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final network = _networks[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: ListTile(
              leading: Icon(_getSignalIcon(network.signalStrength)),
              title: Text(network.ssid),
              subtitle: Wrap(
                spacing: 8.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(network.signalStrength),
                  Chip(
                    label: Text(
                      network.encryption.toUpperCase(),
                      style: const TextStyle(fontSize: 11),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              trailing: network.isSecure ? const Icon(Icons.lock) : null,
              onTap: (_isLoading || _isScanning)
                  ? null
                  : () => _handleNetworkSelection(network),
            ),
          );
        },
      ),
    );
  }
}
