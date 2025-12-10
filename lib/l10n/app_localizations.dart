import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'GL.iNet Connect'**
  String get appTitle;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'GL.iNet Connect'**
  String get appName;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Router Login'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your router\'s admin password.'**
  String get loginSubtitle;

  /// No description provided for @adminPassword.
  ///
  /// In en, this message translates to:
  /// **'Admin Password'**
  String get adminPassword;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter the admin password'**
  String get pleaseEnterPassword;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @setUpWifiRepeater.
  ///
  /// In en, this message translates to:
  /// **'Set Up Wi-Fi Repeater'**
  String get setUpWifiRepeater;

  /// No description provided for @lastCheckedJustNow.
  ///
  /// In en, this message translates to:
  /// **'Last checked: just now'**
  String get lastCheckedJustNow;

  /// No description provided for @lastCheckedSecondsAgo.
  ///
  /// In en, this message translates to:
  /// **'Last checked: {seconds} seconds ago'**
  String lastCheckedSecondsAgo(int seconds);

  /// No description provided for @lastCheckedMinuteAgo.
  ///
  /// In en, this message translates to:
  /// **'Last checked: 1 minute ago'**
  String get lastCheckedMinuteAgo;

  /// No description provided for @lastCheckedMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'Last checked: {minutes} minutes ago'**
  String lastCheckedMinutesAgo(int minutes);

  /// No description provided for @lastCheckedHourAgo.
  ///
  /// In en, this message translates to:
  /// **'Last checked: 1 hour ago'**
  String get lastCheckedHourAgo;

  /// No description provided for @lastCheckedHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'Last checked: {hours} hours ago'**
  String lastCheckedHoursAgo(int hours);

  /// No description provided for @phoneWifi.
  ///
  /// In en, this message translates to:
  /// **'Phone Wi-Fi'**
  String get phoneWifi;

  /// No description provided for @currentlyConnected.
  ///
  /// In en, this message translates to:
  /// **'Currently Connected:'**
  String get currentlyConnected;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not Connected'**
  String get notConnected;

  /// No description provided for @phoneWifiDescription.
  ///
  /// In en, this message translates to:
  /// **'This is the network your phone is using.'**
  String get phoneWifiDescription;

  /// No description provided for @routerInternetStatus.
  ///
  /// In en, this message translates to:
  /// **'Router Internet Status'**
  String get routerInternetStatus;

  /// No description provided for @routerInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'Router Internet Connection'**
  String get routerInternetConnection;

  /// No description provided for @checkingConnection.
  ///
  /// In en, this message translates to:
  /// **'Checking connection...'**
  String get checkingConnection;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @routerOnlineDescription.
  ///
  /// In en, this message translates to:
  /// **'Your router is online and accessing the internet.'**
  String get routerOnlineDescription;

  /// No description provided for @routerOfflineDescription.
  ///
  /// In en, this message translates to:
  /// **'The router is not connected to the internet.'**
  String get routerOfflineDescription;

  /// No description provided for @wifiConfigurationList.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi Configuration List'**
  String get wifiConfigurationList;

  /// No description provided for @chooseNetworkToRepeat.
  ///
  /// In en, this message translates to:
  /// **'Choose a network for the router to repeat.'**
  String get chooseNetworkToRepeat;

  /// No description provided for @noNetworksFound.
  ///
  /// In en, this message translates to:
  /// **'No networks found.\nTap refresh to scan again.'**
  String get noNetworksFound;

  /// No description provided for @scanFailed.
  ///
  /// In en, this message translates to:
  /// **'Scan failed: {error}'**
  String scanFailed(String error);

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed: {error}'**
  String connectionFailed(String error);

  /// No description provided for @connectedTo.
  ///
  /// In en, this message translates to:
  /// **'Connected to {ssid}'**
  String connectedTo(String ssid);

  /// No description provided for @enterPasswordFor.
  ///
  /// In en, this message translates to:
  /// **'Enter password for'**
  String get enterPasswordFor;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @scanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQrCode;

  /// No description provided for @scanWifiQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan WiFi QR Code'**
  String get scanWifiQrCode;

  /// No description provided for @toggleFlash.
  ///
  /// In en, this message translates to:
  /// **'Toggle flash'**
  String get toggleFlash;

  /// No description provided for @pointCameraAtQr.
  ///
  /// In en, this message translates to:
  /// **'Point your camera at a WiFi QR code'**
  String get pointCameraAtQr;

  /// No description provided for @invalidWifiQrCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid WiFi QR code'**
  String get invalidWifiQrCode;

  /// No description provided for @qrCodeNoValidSsid.
  ///
  /// In en, this message translates to:
  /// **'QR code does not contain a valid SSID'**
  String get qrCodeNoValidSsid;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @routerUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Router Unreachable'**
  String get routerUnreachable;

  /// No description provided for @routerUnreachableMessage.
  ///
  /// In en, this message translates to:
  /// **'Router unreachable. Please connect to the GL.iNet router network.'**
  String get routerUnreachableMessage;

  /// No description provided for @authenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication Failed'**
  String get authenticationFailed;

  /// No description provided for @storedCredentialsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Stored credentials are invalid. Please log in again.'**
  String get storedCredentialsInvalid;

  /// No description provided for @autoLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Auto-login failed. Please log in manually.'**
  String get autoLoginFailed;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccessful;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network Error'**
  String get networkError;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginFailed;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred: {error}'**
  String unexpectedError(String error);

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session Expired'**
  String get sessionExpired;

  /// No description provided for @sessionExpiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again to continue.'**
  String get sessionExpiredMessage;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @rateTheApp.
  ///
  /// In en, this message translates to:
  /// **'Rate the App'**
  String get rateTheApp;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @howToUse.
  ///
  /// In en, this message translates to:
  /// **'How to Use'**
  String get howToUse;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get gotIt;

  /// No description provided for @helpStep1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Connect to Your Router'**
  String get helpStep1Title;

  /// No description provided for @helpStep1Description.
  ///
  /// In en, this message translates to:
  /// **'Make sure your phone is connected to your GL.iNet router\'s WiFi network.'**
  String get helpStep1Description;

  /// No description provided for @helpStep2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Log In'**
  String get helpStep2Title;

  /// No description provided for @helpStep2Description.
  ///
  /// In en, this message translates to:
  /// **'Enter your router admin password (the same one you use for the web interface).'**
  String get helpStep2Description;

  /// No description provided for @helpStep3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Scan for Networks'**
  String get helpStep3Title;

  /// No description provided for @helpStep3Description.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Set Up Wi-Fi Repeater\" to scan for available WiFi networks to repeat.'**
  String get helpStep3Description;

  /// No description provided for @helpStep4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Select & Connect'**
  String get helpStep4Title;

  /// No description provided for @helpStep4Description.
  ///
  /// In en, this message translates to:
  /// **'Choose a network and enter its password. Your router will extend that network\'s coverage.'**
  String get helpStep4Description;

  /// No description provided for @helpStep5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Verify Connection'**
  String get helpStep5Title;

  /// No description provided for @helpStep5Description.
  ///
  /// In en, this message translates to:
  /// **'The dashboard shows your router\'s internet status. Green means connected!'**
  String get helpStep5Description;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Configure your GL.iNet router as a WiFi repeater with ease.'**
  String get aboutDescription;

  /// No description provided for @inAppReviewNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'In-app review is not available. The app store listing will open once the app is published.'**
  String get inAppReviewNotAvailable;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location Permission Required'**
  String get locationPermissionRequired;

  /// No description provided for @locationPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'To display the WiFi network name, location permission is needed. Please enable it in app settings.'**
  String get locationPermissionMessage;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @notConnectedToRouter.
  ///
  /// In en, this message translates to:
  /// **'Not Connected to Router'**
  String get notConnectedToRouter;

  /// No description provided for @notConnectedToRouterMessage.
  ///
  /// In en, this message translates to:
  /// **'Please connect your device to a GL.iNet router\'s WiFi network to use this app.'**
  String get notConnectedToRouterMessage;

  /// No description provided for @openWifiSettings.
  ///
  /// In en, this message translates to:
  /// **'Open WiFi Settings'**
  String get openWifiSettings;

  /// No description provided for @checkConnection.
  ///
  /// In en, this message translates to:
  /// **'Check Connection'**
  String get checkConnection;

  /// No description provided for @checkingRouterConnection.
  ///
  /// In en, this message translates to:
  /// **'Checking router connection...'**
  String get checkingRouterConnection;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
