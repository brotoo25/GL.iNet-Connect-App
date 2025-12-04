// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GL.iNet Connect';

  @override
  String get appName => 'GL.iNet Connect';

  @override
  String get loginTitle => 'Router Login';

  @override
  String get loginSubtitle => 'Enter your router\'s admin password.';

  @override
  String get adminPassword => 'Admin Password';

  @override
  String get passwordHint => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get login => 'Login';

  @override
  String get pleaseEnterPassword => 'Please enter the admin password';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get setUpWifiRepeater => 'Set Up Wi-Fi Repeater';

  @override
  String get lastCheckedJustNow => 'Last checked: just now';

  @override
  String lastCheckedSecondsAgo(int seconds) {
    return 'Last checked: $seconds seconds ago';
  }

  @override
  String get lastCheckedMinuteAgo => 'Last checked: 1 minute ago';

  @override
  String lastCheckedMinutesAgo(int minutes) {
    return 'Last checked: $minutes minutes ago';
  }

  @override
  String get lastCheckedHourAgo => 'Last checked: 1 hour ago';

  @override
  String lastCheckedHoursAgo(int hours) {
    return 'Last checked: $hours hours ago';
  }

  @override
  String get phoneWifi => 'Phone Wi-Fi';

  @override
  String get currentlyConnected => 'Currently Connected:';

  @override
  String get notConnected => 'Not Connected';

  @override
  String get phoneWifiDescription => 'This is the network your phone is using.';

  @override
  String get routerInternetStatus => 'Router Internet Status';

  @override
  String get routerInternetConnection => 'Router Internet Connection';

  @override
  String get checkingConnection => 'Checking connection...';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get routerOnlineDescription =>
      'Your router is online and accessing the internet.';

  @override
  String get routerOfflineDescription =>
      'The router is not connected to the internet.';

  @override
  String get wifiConfigurationList => 'Wi-Fi Configuration List';

  @override
  String get chooseNetworkToRepeat =>
      'Choose a network for the router to repeat.';

  @override
  String get noNetworksFound =>
      'No networks found.\nTap refresh to scan again.';

  @override
  String scanFailed(String error) {
    return 'Scan failed: $error';
  }

  @override
  String connectionFailed(String error) {
    return 'Connection failed: $error';
  }

  @override
  String connectedTo(String ssid) {
    return 'Connected to $ssid';
  }

  @override
  String get enterPasswordFor => 'Enter password for';

  @override
  String get cancel => 'Cancel';

  @override
  String get connect => 'Connect';

  @override
  String get scanQrCode => 'Scan QR Code';

  @override
  String get scanWifiQrCode => 'Scan WiFi QR Code';

  @override
  String get toggleFlash => 'Toggle flash';

  @override
  String get pointCameraAtQr => 'Point your camera at a WiFi QR code';

  @override
  String get invalidWifiQrCode => 'Invalid WiFi QR code';

  @override
  String get qrCodeNoValidSsid => 'QR code does not contain a valid SSID';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get ok => 'OK';

  @override
  String get retry => 'Retry';

  @override
  String get routerUnreachable => 'Router Unreachable';

  @override
  String get routerUnreachableMessage =>
      'Router unreachable. Please connect to the GL.iNet router network.';

  @override
  String get authenticationFailed => 'Authentication Failed';

  @override
  String get storedCredentialsInvalid =>
      'Stored credentials are invalid. Please log in again.';

  @override
  String get autoLoginFailed => 'Auto-login failed. Please log in manually.';

  @override
  String get loginSuccessful => 'Login successful';

  @override
  String get networkError => 'Network Error';

  @override
  String get loginFailed => 'Login Failed';

  @override
  String unexpectedError(String error) {
    return 'An unexpected error occurred: $error';
  }

  @override
  String get sessionExpired => 'Session Expired';

  @override
  String get sessionExpiredMessage =>
      'Your session has expired. Please log in again to continue.';

  @override
  String get help => 'Help';

  @override
  String get rateTheApp => 'Rate the App';

  @override
  String get about => 'About';

  @override
  String get howToUse => 'How to Use';

  @override
  String get gotIt => 'Got it!';

  @override
  String get helpStep1Title => '1. Connect to Your Router';

  @override
  String get helpStep1Description =>
      'Make sure your phone is connected to your GL.iNet router\'s WiFi network.';

  @override
  String get helpStep2Title => '2. Log In';

  @override
  String get helpStep2Description =>
      'Enter your router admin password (the same one you use for the web interface).';

  @override
  String get helpStep3Title => '3. Scan for Networks';

  @override
  String get helpStep3Description =>
      'Tap \"Set Up Wi-Fi Repeater\" to scan for available WiFi networks to repeat.';

  @override
  String get helpStep4Title => '4. Select & Connect';

  @override
  String get helpStep4Description =>
      'Choose a network and enter its password. Your router will extend that network\'s coverage.';

  @override
  String get helpStep5Title => '5. Verify Connection';

  @override
  String get helpStep5Description =>
      'The dashboard shows your router\'s internet status. Green means connected!';

  @override
  String get aboutDescription =>
      'Configure your GL.iNet router as a WiFi repeater with ease.';

  @override
  String get inAppReviewNotAvailable =>
      'In-app review is not available. The app store listing will open once the app is published.';

  @override
  String get locationPermissionRequired => 'Location Permission Required';

  @override
  String get locationPermissionMessage =>
      'To display the WiFi network name, location permission is needed. Please enable it in app settings.';

  @override
  String get openSettings => 'Open Settings';
}
