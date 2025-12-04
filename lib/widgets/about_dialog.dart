import 'package:flutter/material.dart';

/// Shows an about dialog with app information
void showAppAboutDialog(BuildContext context) {
  showAboutDialog(
    context: context,
    applicationName: 'GL.iNet Connect',
    applicationVersion: '1.0.0',
    applicationIcon: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset('assets/logo.png', width: 48, height: 48),
    ),
    children: [
      const Text(
        'Configure your GL.iNet router as a WiFi repeater with ease.',
      ),
    ],
  );
}
