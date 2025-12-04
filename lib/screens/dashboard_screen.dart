import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../services/glinet_api_service.dart';
import '../services/wifi_info_service.dart';
import '../widgets/about_dialog.dart';
import '../widgets/app_drawer.dart';
import '../widgets/help_dialog.dart';
import '../widgets/phone_wifi_card.dart';
import '../widgets/rate_app_dialog.dart';
import '../widgets/router_connection_card.dart';

/// Dashboard screen displayed after successful login
class DashboardScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback onSetupRepeater;
  final GlinetApiService apiService;

  const DashboardScreen({
    super.key,
    required this.onLogout,
    required this.onSetupRepeater,
    required this.apiService,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final WifiInfoService _wifiInfoService = WifiInfoService();

  RouterConnectionState _connectionState = RouterConnectionState.checking;
  List<PingResult>? _pingResults;
  String? _connectedNetwork;
  DateTime? _lastChecked;
  Timer? _refreshTimer;
  Timer? _lastCheckedTimer;
  StreamSubscription<dynamic>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initializeWithPermission();
    _startConnectivityListener();
    _startLastCheckedTimer();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _lastCheckedTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  /// Start a timer that updates the "Last checked" text every second
  void _startLastCheckedTimer() {
    _lastCheckedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_lastChecked != null && mounted) {
        setState(() {});
      }
    });
  }

  /// Start listening for WiFi connectivity changes
  void _startConnectivityListener() {
    _connectivitySubscription =
        _wifiInfoService.onConnectivityChanged.listen((result) async {
      // When connectivity changes, refresh WiFi info and connection status
      debugPrint('Connectivity changed: $result');

      // Update router IP based on new network gateway
      await _updateRouterIp();

      _loadWifiInfo();
      _checkConnection();
    });
  }

  /// Update the router IP based on the current network gateway
  Future<void> _updateRouterIp() async {
    try {
      final gatewayIP = await _wifiInfoService.getWifiGatewayIP();
      if (gatewayIP != null && gatewayIP.isNotEmpty) {
        debugPrint('Updating router IP to gateway: $gatewayIP');
        widget.apiService.updateRouterIp(gatewayIP);
      }
    } catch (e) {
      debugPrint('Error updating router IP: $e');
    }
  }

  /// Initialize by requesting location permission first, then load data
  Future<void> _initializeWithPermission() async {
    // Request location permission (required to get WiFi SSID)
    final status = await Permission.locationWhenInUse.request();

    if (status.isGranted) {
      await _loadWifiInfo();
    } else if (status.isPermanentlyDenied) {
      // Show dialog to open settings if permission is permanently denied
      if (mounted) {
        _showPermissionDeniedDialog();
      }
    }

    _checkConnection();

    // Auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        _loadWifiInfo();
        _checkConnection();
      },
    );
  }

  /// Show a dialog when permission is permanently denied
  void _showPermissionDeniedDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.locationPermissionRequired),
        content: Text(l10n.locationPermissionMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: Text(l10n.openSettings),
          ),
        ],
      ),
    );
  }

  /// Load the current WiFi network name from the device
  Future<void> _loadWifiInfo() async {
    final wifiInfo = await _wifiInfoService.getWifiConnectionInfo();
    if (mounted) {
      setState(() {
        _connectedNetwork = wifiInfo.ssid;
      });
    }
  }

  Future<void> _checkConnection() async {
    setState(() {
      _connectionState = RouterConnectionState.checking;
    });

    try {
      // Use the API service to check actual internet connectivity
      final status = await widget.apiService.checkInternetStatus();
      final isConnected = status['connected'] as bool;
      final pingResultsData =
          status['pingResults'] as List<Map<String, dynamic>>;

      if (mounted) {
        setState(() {
          _connectionState = isConnected
              ? RouterConnectionState.connected
              : RouterConnectionState.disconnected;

          // Convert ping results to PingResult objects (include all, even failed)
          _pingResults = pingResultsData
              .map((r) => PingResult(
                    provider: r['provider'] as String,
                    ips: List<String>.from(r['ips'] as List),
                    success: r['success'] as bool,
                  ))
              .toList();

          _lastChecked = DateTime.now();
        });
      }
    } catch (e) {
      // On error, show disconnected state
      if (mounted) {
        setState(() {
          _connectionState = RouterConnectionState.disconnected;
          _pingResults = null;
          _lastChecked = DateTime.now();
        });
      }
    }
  }

  String _getLastCheckedText(AppLocalizations l10n) {
    if (_lastChecked == null) return '';
    final diff = DateTime.now().difference(_lastChecked!);
    if (diff.inSeconds < 5) {
      return l10n.lastCheckedJustNow;
    } else if (diff.inSeconds < 60) {
      return l10n.lastCheckedSecondsAgo(diff.inSeconds);
    } else if (diff.inMinutes < 60) {
      final mins = diff.inMinutes;
      return mins == 1
          ? l10n.lastCheckedMinuteAgo
          : l10n.lastCheckedMinutesAgo(mins);
    } else {
      final hours = diff.inHours;
      return hours == 1
          ? l10n.lastCheckedHourAgo
          : l10n.lastCheckedHoursAgo(hours);
    }
  }

  void _showHelp() => showHelpDialog(context);

  Future<void> _showRateApp() => requestAppReview(context);

  void _showAbout() => showAppAboutDialog(context);

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard),
      ),
      drawer: AppDrawer(
        onLogout: widget.onLogout,
        onHelp: _showHelp,
        onRateApp: _showRateApp,
        onAbout: _showAbout,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Phone WiFi Card (always visible)
                    PhoneWifiCard(
                      networkName: _connectedNetwork,
                      isConnected: _connectedNetwork != null,
                    ),
                    const SizedBox(height: 16),
                    // Router Connection Card (with different states)
                    RouterConnectionCard(
                      state: _connectionState,
                      pingResults: _pingResults,
                    ),
                  ],
                ),
              ),
            ),
            // Bottom section with button and last checked text
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  FilledButton(
                    onPressed: widget.onSetupRepeater,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l10n.setUpWifiRepeater),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getLastCheckedText(l10n),
                    style: TextStyle(
                      color: appColors.subtitleGray,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
