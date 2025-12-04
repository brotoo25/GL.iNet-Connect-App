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
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  /// Get the current WiFi network name (SSID)
  Future<String?> getWifiName() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final status = await Permission.locationWhenInUse.request();
        if (!status.isGranted) {
          debugPrint('Location permission denied - cannot get WiFi name');
          return null;
        }
      }

      String? wifiName = await _networkInfo.getWifiName();
      if (wifiName != null) {
        wifiName = wifiName.replaceAll('"', '');
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

  /// Get the gateway IP address (router IP)
  Future<String?> getWifiGatewayIP() async {
    try {
      return await _networkInfo.getWifiGatewayIP();
    } catch (e) {
      debugPrint('Error getting WiFi gateway IP: $e');
      return null;
    }
  }

  /// Get WiFi connection info (SSID only)
  Future<WifiConnectionInfo> getWifiConnectionInfo() async {
    final ssid = await getWifiName();
    return WifiConnectionInfo(ssid: ssid);
  }
}

/// Model class for WiFi connection information
class WifiConnectionInfo {
  final String? ssid;
  const WifiConnectionInfo({this.ssid});
}
