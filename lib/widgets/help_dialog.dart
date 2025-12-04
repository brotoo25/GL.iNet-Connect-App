import 'package:flutter/material.dart';
import '../main.dart';

/// Shows a help dialog explaining how to use the app
void showHelpDialog(BuildContext context) {
  final appColors = Theme.of(context).extension<AppColors>()!;

  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: appColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            Icons.help_outline,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          const Text('How to Use', style: TextStyle(color: Colors.white)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _HelpSection(
              appColors: appColors,
              icon: Icons.wifi,
              title: '1. Connect to Your Router',
              description:
                  'Make sure your phone is connected to your GL.iNet router\'s WiFi network.',
            ),
            const SizedBox(height: 16),
            _HelpSection(
              appColors: appColors,
              icon: Icons.login,
              title: '2. Log In',
              description:
                  'Enter your router admin password (the same one you use for the web interface).',
            ),
            const SizedBox(height: 16),
            _HelpSection(
              appColors: appColors,
              icon: Icons.search,
              title: '3. Scan for Networks',
              description:
                  'Tap "Set Up Wi-Fi Repeater" to scan for available WiFi networks to repeat.',
            ),
            const SizedBox(height: 16),
            _HelpSection(
              appColors: appColors,
              icon: Icons.wifi_tethering,
              title: '4. Select & Connect',
              description:
                  'Choose a network and enter its password. Your router will extend that network\'s coverage.',
            ),
            const SizedBox(height: 16),
            _HelpSection(
              appColors: appColors,
              icon: Icons.check_circle_outline,
              title: '5. Verify Connection',
              description:
                  'The dashboard shows your router\'s internet status. Green means connected!',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Got it!'),
        ),
      ],
    ),
  );
}

class _HelpSection extends StatelessWidget {
  final AppColors appColors;
  final IconData icon;
  final String title;
  final String description;

  const _HelpSection({
    required this.appColors,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: appColors.successGreen, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: appColors.subtitleGray,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
