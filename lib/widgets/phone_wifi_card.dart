import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

/// Card widget showing the phone's current WiFi connection
/// This card is always displayed on the dashboard
class PhoneWifiCard extends StatelessWidget {
  final String? networkName;
  final bool isConnected;

  const PhoneWifiCard({
    super.key,
    this.networkName,
    this.isConnected = false,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.phoneWifi,
            style: TextStyle(
              color: appColors.subtitleGray,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isConnected ? Icons.wifi : Icons.wifi_off,
                color:
                    isConnected ? appColors.successGreen : appColors.errorRed,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                isConnected ? l10n.currentlyConnected : l10n.notConnected,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (isConnected && networkName != null) ...[
            const SizedBox(height: 8),
            Text(
              networkName!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.phoneWifiDescription,
              style: TextStyle(
                color: appColors.subtitleGray,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
