import 'package:flutter/material.dart';
import '../main.dart';
import '../models/wifi_network.dart';
import '../models/exceptions.dart';
import '../services/glinet_api_service.dart';

/// Screen for setting up the WiFi repeater
class RepeaterSetupScreen extends StatefulWidget {
  final GlinetApiService apiService;
  final VoidCallback? onSessionExpired;

  const RepeaterSetupScreen({
    super.key,
    required this.apiService,
    this.onSessionExpired,
  });

  @override
  State<RepeaterSetupScreen> createState() => _RepeaterSetupScreenState();
}

class _RepeaterSetupScreenState extends State<RepeaterSetupScreen> {
  bool _isScanning = false;
  bool _isConnecting = false;
  List<WifiNetwork> _networks = [];

  @override
  void initState() {
    super.initState();
    _scanNetworks();
  }

  Future<void> _scanNetworks() async {
    if (_isScanning || _isConnecting) return;
    setState(() => _isScanning = true);

    try {
      final networks = await widget.apiService.scanWifi();
      networks.sort((a, b) => b.signal.compareTo(a.signal));
      setState(() => _networks = networks);
    } on SessionExpiredException {
      widget.onSessionExpired?.call();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _showErrorSnackBar('Scan failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Future<void> _handleNetworkSelection(WifiNetwork network) async {
    if (_isConnecting || _isScanning) return;

    if (!network.isSecure) {
      await _connectToNetwork(network, '');
      return;
    }

    final password = await _showPasswordDialog(network);
    if (password != null && mounted) {
      await _connectToNetwork(network, password);
    }
  }

  Future<void> _connectToNetwork(WifiNetwork network, String password) async {
    setState(() => _isConnecting = true);

    try {
      await widget.apiService.connectRepeater(
        ssid: network.ssid,
        password: password,
        bssid: network.bssid,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connected to ${network.ssid}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } on SessionExpiredException {
      widget.onSessionExpired?.call();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _showErrorSnackBar('Connection failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  IconData _getSignalIcon(int signal) {
    if (signal >= -50) return Icons.network_wifi;
    if (signal >= -60) return Icons.network_wifi;
    if (signal >= -70) return Icons.network_wifi_2_bar;
    return Icons.network_wifi_1_bar;
  }

  String _getEncryptionDisplay(String encryption) {
    final enc = encryption.toLowerCase();
    if (enc.contains('wpa3') || enc == 'sae') return 'WPA3';
    if (enc.contains('wpa2') || enc == 'psk2') return 'WPA2';
    if (enc.contains('wpa') || enc == 'psk') return 'WPA';
    if (enc == 'none' || enc == 'open') return 'Open';
    return encryption.toUpperCase();
  }

  Future<String?> _showPasswordDialog(WifiNetwork network) async {
    final passwordController = TextEditingController();
    bool obscurePassword = true;
    final appColors = Theme.of(context).extension<AppColors>()!;

    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: appColors.cardBackground,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            children: [
              const Text('Enter password for',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(network.ssid,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          content: TextField(
            controller: passwordController,
            obscureText: obscurePassword,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: appColors.inputBackground,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              suffixIcon: IconButton(
                icon: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: appColors.subtitleGray),
                onPressed: () =>
                    setDialogState(() => obscurePassword = !obscurePassword),
              ),
            ),
            onSubmitted: (_) => Navigator.pop(context, passwordController.text),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: appColors.subtitleGray),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.pop(context, passwordController.text),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Connect'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Wi-Fi Configuration List'),
        actions: [
          IconButton(
            icon: _isScanning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isScanning ? null : _scanNetworks,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Choose a network for the router to repeat.',
              style: TextStyle(color: appColors.subtitleGray, fontSize: 14),
            ),
          ),
          Expanded(
            child: _isScanning && _networks.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _networks.isEmpty
                    ? Center(
                        child: Text(
                          'No networks found.\nTap refresh to scan again.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: appColors.subtitleGray),
                        ),
                      )
                    : _buildNetworkList(appColors),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkList(AppColors appColors) {
    return IgnorePointer(
      ignoring: _isConnecting,
      child: Opacity(
        opacity: _isConnecting ? 0.5 : 1.0,
        child: ListView.builder(
          itemCount: _networks.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final network = _networks[index];
            return _NetworkListItem(
              network: network,
              signalIcon: _getSignalIcon(network.signal),
              encryptionDisplay: _getEncryptionDisplay(network.encryption),
              appColors: appColors,
              onTap: () => _handleNetworkSelection(network),
            );
          },
        ),
      ),
    );
  }
}

class _NetworkListItem extends StatelessWidget {
  final WifiNetwork network;
  final IconData signalIcon;
  final String encryptionDisplay;
  final AppColors appColors;
  final VoidCallback onTap;

  const _NetworkListItem({
    required this.network,
    required this.signalIcon,
    required this.encryptionDisplay,
    required this.appColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: appColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          network.ssid,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            encryptionDisplay,
            style: TextStyle(color: appColors.subtitleGray, fontSize: 14),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(signalIcon, color: Colors.white, size: 22),
            if (network.isSecure) ...[
              const SizedBox(width: 4),
              const Icon(Icons.lock, color: Colors.white, size: 16),
            ],
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
