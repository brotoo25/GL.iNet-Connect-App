# GL.iNet Connect

GL.iNet Connect is a Flutter app for configuring GL.iNet routers as Wi-Fi repeaters.

It lets you log into a GL.iNet router, check its internet connectivity, and quickly set up
Wi-Fi repeater networks from your phone.

## Features

- Connect to GL.iNet routers over the local network using the JSON-RPC API
- Secure login with stored admin credentials (using flutter_secure_storage)
- Dynamic router IP detection based on the current Wi-Fi gateway
- Dashboard showing:
  - Phone Wi-Fi connection status
  - Router internet connectivity with per-provider ping results
  - "Last checked" timestamp that updates every second
- Guided Wi-Fi repeater setup flow
- Scan Wi-Fi QR codes to automatically fill in network credentials
- Localized UI (English, Portuguese, Spanish)
- Mobile-first UI built with Material 3

## Prerequisites

- Flutter SDK matching the version constraints in pubspec.yaml
- A GL.iNet router running firmware 4.x reachable from your device

## Setup

1. Clone this repository.
2. From the project root, run `flutter pub get` to install dependencies.
3. Connect a device or start an emulator.
4. Run `flutter run` to launch the app.

## Project structure

- lib/main.dart – App entrypoint, theming, localization
- lib/screens/ – Login, dashboard, repeater setup, app shell
- lib/services/ – Router API, Wi-Fi info, credential storage, crypto helper
- lib/models/ – Data models for API responses and Wi-Fi networks
- lib/widgets/ – Reusable UI components (cards, dialogs, drawer, etc.)
- lib/l10n/ – ARB files for localization

## Localization

User-visible strings live in the ARB files under lib/l10n/:

- app_en.arb – English (default)
- app_pt.arb – Portuguese
- app_es.arb – Spanish

Use the generated AppLocalizations class in widgets instead of hardcoded strings.

## Router integration

- Router IP is detected dynamically from the current Wi-Fi gateway using network_info_plus.
- Authentication and JSON-RPC calls are handled by GlinetApiService.
- Admin credentials can be stored securely on device to enable auto-login.

## Contributing

Contributions are welcome.

- Use GitHub issues to report bugs or request features.
- Fork the repo and open pull requests with clear descriptions.
- Keep UI text localized via AppLocalizations.
- Run `flutter analyze` and any relevant tests before submitting a PR.

## License

This project is licensed under the GNU General Public License version 3 (GPLv3) or later.
See the LICENSE file for full details.