/// Model class representing a scanned WiFi network
class WifiNetwork {
  /// Network name (SSID)
  final String ssid;

  /// MAC address of the access point
  final String bssid;

  /// Signal strength in dBm (e.g., -50, -70)
  final int signal;

  /// Security type (e.g., 'psk', 'psk2', 'wpa3', 'none')
  final String encryption;

  /// Frequency band ('2g', '5g', '6g')
  final String? band;

  /// WiFi channel number
  final int? channel;

  /// Constructor with named parameters
  WifiNetwork({
    required this.ssid,
    required this.bssid,
    required this.signal,
    required this.encryption,
    this.band,
    this.channel,
  });

  /// Factory constructor to parse JSON from router API response
  factory WifiNetwork.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse int from dynamic value
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Support alternate key 'rssi' for signal
    final signalValue = json['signal'] ?? json['rssi'];
    final signal = parseInt(signalValue) ?? -100;

    // Support alternate key 'channel' parsing
    final channelValue = json['channel'];
    final channel = parseInt(channelValue);

    return WifiNetwork(
      ssid: (json['ssid'] as String?) ?? '',
      bssid: (json['bssid'] as String?) ?? '',
      signal: signal,
      encryption: _parseEncryption(json['encryption']),
      band: json['band'] as String?,
      channel: channel,
    );
  }

  static String _parseEncryption(dynamic encryptionValue) {
    if (encryptionValue == null) return 'none';
    if (encryptionValue is String) return encryptionValue;
    if (encryptionValue is Map<String, dynamic>) {
      final desc = encryptionValue['description'];
      if (desc is String && desc.isNotEmpty) {
        return desc;
      }
      final enabled = encryptionValue['enabled'] == true;
      return enabled ? 'on' : 'open';
    }
    return 'none';
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'ssid': ssid,
      'bssid': bssid,
      'signal': signal,
      'encryption': encryption,
      if (band != null) 'band': band,
      if (channel != null) 'channel': channel,
    };
  }

  /// Returns a human-readable signal strength description
  String get signalStrength {
    if (signal >= -50) {
      return 'Excellent';
    } else if (signal >= -60) {
      return 'Good';
    } else if (signal >= -70) {
      return 'Fair';
    } else {
      return 'Weak';
    }
  }

  /// Returns true if the network is secured (not open)
  bool get isSecure {
    return encryption != 'none';
  }

  @override
  String toString() {
    return 'WifiNetwork(ssid: $ssid, bssid: $bssid, signal: $signal dBm, '
        'encryption: $encryption, band: $band, channel: $channel, '
        'strength: $signalStrength)';
  }
}
