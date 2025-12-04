import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../l10n/app_localizations.dart';
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
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _showErrorSnackBar(l10n.scanFailed(e.toString()));
      }
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
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.connectedTo(network.ssid)),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } on SessionExpiredException {
      widget.onSessionExpired?.call();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _showErrorSnackBar(l10n.connectionFailed(e.toString()));
      }
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

  /// Parse WiFi credentials from QR code data
  /// WiFi QR codes follow the format: `WIFI:T:auth;S:ssid;P:password;;`
  Map<String, String>? _parseWifiQrCode(String data) {
    if (!data.startsWith('WIFI:')) return null;

    final Map<String, String> result = {};
    // Remove WIFI: prefix and trailing ;;
    String content = data.substring(5);
    if (content.endsWith(';;')) {
      content = content.substring(0, content.length - 2);
    }

    // Parse key:value pairs separated by ;
    final parts = content.split(';');
    for (final part in parts) {
      if (part.isEmpty) continue;
      final colonIndex = part.indexOf(':');
      if (colonIndex > 0) {
        final key = part.substring(0, colonIndex);
        final value = part.substring(colonIndex + 1);
        result[key] = value;
      }
    }

    // S = SSID, P = Password, T = Authentication type
    if (result.containsKey('S')) {
      return {
        'ssid': result['S'] ?? '',
        'password': result['P'] ?? '',
        'authType': result['T'] ?? 'WPA',
      };
    }
    return null;
  }

  /// Open QR code scanner and connect to scanned network
  Future<void> _scanQrCode() async {
    final appColors = Theme.of(context).extension<AppColors>()!;

    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => _QrScannerScreen(appColors: appColors),
      ),
    );

    if (result != null && mounted) {
      final wifiCredentials = _parseWifiQrCode(result);
      if (wifiCredentials != null) {
        await _connectWithQrCredentials(wifiCredentials);
      } else {
        final l10n = AppLocalizations.of(context)!;
        _showErrorSnackBar(l10n.invalidWifiQrCode);
      }
    }
  }

  /// Connect to network using QR code credentials
  Future<void> _connectWithQrCredentials(
      Map<String, String> credentials) async {
    final l10n = AppLocalizations.of(context)!;
    final ssid = credentials['ssid'] ?? '';
    final password = credentials['password'] ?? '';

    if (ssid.isEmpty) {
      _showErrorSnackBar(l10n.qrCodeNoValidSsid);
      return;
    }

    setState(() => _isConnecting = true);

    try {
      await widget.apiService.connectRepeater(
        ssid: ssid,
        password: password,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.connectedTo(ssid)),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } on SessionExpiredException {
      widget.onSessionExpired?.call();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(l10n.connectionFailed(e.toString()));
      }
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
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
    final l10n = AppLocalizations.of(context)!;

    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: appColors.cardBackground,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            children: [
              Text(l10n.enterPasswordFor,
                  style: const TextStyle(
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
                    child: Text(l10n.cancel),
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
                    child: Text(l10n.connect),
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l10n.wifiConfigurationList),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _isConnecting ? null : _scanQrCode,
            tooltip: l10n.scanQrCode,
          ),
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
              l10n.chooseNetworkToRepeat,
              style: TextStyle(color: appColors.subtitleGray, fontSize: 14),
            ),
          ),
          Expanded(
            child: _isScanning && _networks.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _networks.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noNetworksFound,
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

/// QR Code Scanner Screen
class _QrScannerScreen extends StatefulWidget {
  final AppColors appColors;

  const _QrScannerScreen({required this.appColors});

  @override
  State<_QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<_QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      _hasScanned = true;
      Navigator.of(context).pop(barcodes.first.rawValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l10n.scanWifiQrCode),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                return Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_on
                      : Icons.flash_off,
                );
              },
            ),
            onPressed: () => _controller.toggleTorch(),
            tooltip: l10n.toggleFlash,
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Overlay with scanning guide
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          // Instructions at the bottom
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Text(
              l10n.pointCameraAtQr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    color: Color(0xCC000000), // Black with 80% opacity
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
