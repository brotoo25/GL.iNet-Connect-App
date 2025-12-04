import 'package:flutter/material.dart';
import '../main.dart';

/// Custom drawer menu for the app
class AppDrawer extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback? onHelp;
  final VoidCallback? onRateApp;
  final VoidCallback? onAbout;

  const AppDrawer({
    super.key,
    required this.onLogout,
    this.onHelp,
    this.onRateApp,
    this.onAbout,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Drawer(
      backgroundColor: appColors.cardBackground,
      child: SafeArea(
        child: Column(
          children: [
            // Header with logo and title
            _buildHeader(context),
            const SizedBox(height: 24),
            // Menu items
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _DrawerMenuItem(
                      icon: Icons.help_outline,
                      iconColor: Theme.of(context).colorScheme.primary,
                      label: 'Help',
                      onTap: () {
                        Navigator.pop(context);
                        onHelp?.call();
                      },
                    ),
                    const SizedBox(height: 8),
                    _DrawerMenuItem(
                      icon: Icons.star,
                      iconColor: Theme.of(context).colorScheme.primary,
                      label: 'Rate the App',
                      onTap: () {
                        Navigator.pop(context);
                        onRateApp?.call();
                      },
                    ),
                    const SizedBox(height: 8),
                    _DrawerMenuItem(
                      icon: Icons.info_outline,
                      iconColor: Theme.of(context).colorScheme.primary,
                      label: 'About',
                      onTap: () {
                        Navigator.pop(context);
                        onAbout?.call();
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Logout button at the bottom
            _buildLogoutButton(context, appColors),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          // Logo placeholder (white square like in the design)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox();
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'GL.iNet Connect',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AppColors appColors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            onLogout();
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: appColors.errorRed,
            side: BorderSide(
              color: appColors.errorRed.withValues(alpha: 0.3),
            ),
            backgroundColor: appColors.errorRed.withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.logout),
          label: const Text(
            'Logout',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback? onTap;

  const _DrawerMenuItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
