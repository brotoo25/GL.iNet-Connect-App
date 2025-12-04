import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for getting device WiFi connection information
class WifiInfoService {
  final NetworkInfo _networkInfo = NetworkInfo();
  final Connectivity _connectivity = Connectivity();

  /// Stream of connectivity changes
  /// Emits whenever the device connects or disconnects from a network
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  /// Get the current WiFi network name (SSID)
  /// Returns null if not connected or permission denied
  Future<String?> getWifiName() async {
    try {
      // Request location permission (required for WiFi info on Android)
      if (Platform.isAndroid || Platform.isIOS) {
        final status = await Permission.locationWhenInUse.request();
        if (!status.isGranted) {
          debugPrint('Location permission denied - cannot get WiFi name');
          return null;
        }
      }

      String? wifiName = await _networkInfo.getWifiName();

      // WiFi name comes with quotes on some platforms, remove them
      if (wifiName != null) {
        wifiName = wifiName.replaceAll('"', '');
        // Check for unknown/empty values
        if (wifiName.isEmpty || wifiName == '<unknown ssid>') {
          return null;
        }
      }

      return wifiName;
    } catch (e) {
      debugPrint('Error getting WiFi name: $e');
      return null;
    }
  }

  /// Get the current WiFi BSSID (router MAC address)
  Future<String?> getWifiBSSID() async {
    try {
      return await _networkInfo.getWifiBSSID();
    } catch (e) {
      debugPrint('Error getting WiFi BSSID: $e');
      return null;
    }
  }

  /// Get the device's IP address on the WiFi network
  Future<String?> getWifiIP() async {
    try {
      return await _networkInfo.getWifiIP();
    } catch (e) {
      debugPrint('Error getting WiFi IP: $e');
      return null;
    }
  }

  /// Get the gateway IP address (router IP)
  /// Returns null if not connected or unavailable
  Future<String?> getWifiGatewayIP() async {
    try {
      final gatewayIP = await _networkInfo.getWifiGatewayIP();
      debugPrint('Gateway IP: $gatewayIP');
      return gatewayIP;
    } catch (e) {
      debugPrint('Error getting WiFi gateway IP: $e');
      return null;
    }
  }

  /// Check if the device is connected to WiFi
  Future<bool> isConnectedToWifi() async {
    final wifiName = await getWifiName();
    return wifiName != null && wifiName.isNotEmpty;
  }

  /// Get complete WiFi connection info
  Future<WifiConnectionInfo> getWifiConnectionInfo() async {
    final name = await getWifiName();
    final bssid = await getWifiBSSID();
    final ip = await getWifiIP();
    final gatewayIP = await getWifiGatewayIP();

    return WifiConnectionInfo(
      ssid: name,
      bssid: bssid,
      ipAddress: ip,
      gatewayIP: gatewayIP,
      isConnected: name != null && name.isNotEmpty,
    );
  }
}

/// Model class for WiFi connection information
class WifiConnectionInfo {
  final String? ssid;
  final String? bssid;
  final String? ipAddress;
  final String? gatewayIP;
  final bool isConnected;

  const WifiConnectionInfo({
    this.ssid,
    this.bssid,
    this.ipAddress,
    this.gatewayIP,
    required this.isConnected,
  });
}
