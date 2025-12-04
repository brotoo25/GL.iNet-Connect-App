import 'package:flutter/material.dart';
import '../main.dart';

/// Enum representing the different states of router internet connection
enum RouterConnectionState {
  checking,
  connected,
  disconnected,
}

/// Model for ping result display
class PingResult {
  final String provider;
  final List<String> ips;
  final bool success;

  const PingResult({
    required this.provider,
    required this.ips,
    this.success = true,
  });
}

/// Card widget showing the router's internet connection status
class RouterConnectionCard extends StatefulWidget {
  final RouterConnectionState state;
  final List<PingResult>? pingResults;

  const RouterConnectionCard({
    super.key,
    required this.state,
    this.pingResults,
  });

  @override
  State<RouterConnectionCard> createState() => _RouterConnectionCardState();
}

class _RouterConnectionCardState extends State<RouterConnectionCard> {
  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final theme = Theme.of(context);

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
            'Router Internet Status',
            style: TextStyle(color: appColors.subtitleGray, fontSize: 12),
          ),
          const SizedBox(height: 8),
          _buildHeader(),
          const SizedBox(height: 8),
          // Animated transition between states
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _buildContent(appColors, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Row(
      children: [
        Icon(Icons.language, color: Colors.white, size: 24),
        SizedBox(width: 12),
        Text(
          'Router Internet Connection',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(AppColors appColors, ThemeData theme) {
    // Key is important for AnimatedSwitcher to detect changes
    switch (widget.state) {
      case RouterConnectionState.checking:
        return _CheckingContent(
          key: const ValueKey('checking'),
          appColors: appColors,
          theme: theme,
        );
      case RouterConnectionState.connected:
        return _ConnectedContent(
          key: const ValueKey('connected'),
          appColors: appColors,
          pingResults: widget.pingResults,
        );
      case RouterConnectionState.disconnected:
        return _DisconnectedContent(
          key: const ValueKey('disconnected'),
          appColors: appColors,
        );
    }
  }
}

class _CheckingContent extends StatelessWidget {
  final AppColors appColors;
  final ThemeData theme;

  const _CheckingContent({
    super.key,
    required this.appColors,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Checking connection...',
          style: TextStyle(color: theme.colorScheme.primary, fontSize: 14),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            minHeight: 4,
            backgroundColor: appColors.inputBackground,
          ),
        ),
      ],
    );
  }
}

class _ConnectedContent extends StatelessWidget {
  final AppColors appColors;
  final List<PingResult>? pingResults;

  const _ConnectedContent({
    super.key,
    required this.appColors,
    this.pingResults,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatusIndicator(color: appColors.successGreen, label: 'Connected'),
        const SizedBox(height: 8),
        Text(
          'Your router is online and accessing the internet.',
          style: TextStyle(color: appColors.subtitleGray, fontSize: 14),
        ),
        if (pingResults != null && pingResults!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildPingResults(),
        ],
      ],
    );
  }

  Widget _buildPingResults() {
    return Row(
      children: pingResults!
          .map((r) => Expanded(
              child: _PingResultColumn(result: r, appColors: appColors)))
          .toList(),
    );
  }
}

class _DisconnectedContent extends StatelessWidget {
  final AppColors appColors;

  const _DisconnectedContent({super.key, required this.appColors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatusIndicator(color: appColors.errorRed, label: 'Disconnected'),
        const SizedBox(height: 8),
        Text(
          'The router is not connected to the internet.',
          style: TextStyle(color: appColors.subtitleGray, fontSize: 14),
        ),
      ],
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final Color color;
  final String label;

  const _StatusIndicator({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
              color: color, fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _PingResultColumn extends StatelessWidget {
  final PingResult result;
  final AppColors appColors;

  const _PingResultColumn({required this.result, required this.appColors});

  @override
  Widget build(BuildContext context) {
    // Use green for successful pings, red for failed ones
    final indicatorColor =
        result.success ? appColors.successGreen : appColors.errorRed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          result.provider,
          style: TextStyle(color: appColors.subtitleGray, fontSize: 12),
        ),
        const SizedBox(height: 4),
        ...result.ips.map((ip) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: indicatorColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(ip,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            )),
      ],
    );
  }
}
