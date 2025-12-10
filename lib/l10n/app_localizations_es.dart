// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'GL.iNet Connect';

  @override
  String get appName => 'GL.iNet Connect';

  @override
  String get loginTitle => 'Inicio de Sesión del Router';

  @override
  String get loginSubtitle =>
      'Ingresa la contraseña de administrador de tu router.';

  @override
  String get adminPassword => 'Contraseña de Administrador';

  @override
  String get passwordHint => 'Contraseña';

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get hidePassword => 'Ocultar contraseña';

  @override
  String get login => 'Iniciar Sesión';

  @override
  String get pleaseEnterPassword =>
      'Por favor, ingresa la contraseña de administrador';

  @override
  String get dashboard => 'Panel';

  @override
  String get setUpWifiRepeater => 'Configurar Repetidor Wi-Fi';

  @override
  String get lastCheckedJustNow => 'Verificado: justo ahora';

  @override
  String lastCheckedSecondsAgo(int seconds) {
    return 'Verificado: hace $seconds segundos';
  }

  @override
  String get lastCheckedMinuteAgo => 'Verificado: hace 1 minuto';

  @override
  String lastCheckedMinutesAgo(int minutes) {
    return 'Verificado: hace $minutes minutos';
  }

  @override
  String get lastCheckedHourAgo => 'Verificado: hace 1 hora';

  @override
  String lastCheckedHoursAgo(int hours) {
    return 'Verificado: hace $hours horas';
  }

  @override
  String get phoneWifi => 'Wi-Fi del Teléfono';

  @override
  String get currentlyConnected => 'Conectado Actualmente:';

  @override
  String get notConnected => 'No Conectado';

  @override
  String get phoneWifiDescription =>
      'Esta es la red que tu teléfono está usando.';

  @override
  String get routerInternetStatus => 'Estado de Internet del Router';

  @override
  String get routerInternetConnection => 'Conexión de Internet del Router';

  @override
  String get checkingConnection => 'Verificando conexión...';

  @override
  String get connected => 'Conectado';

  @override
  String get disconnected => 'Desconectado';

  @override
  String get routerOnlineDescription =>
      'Tu router está en línea y accediendo a internet.';

  @override
  String get routerOfflineDescription =>
      'El router no está conectado a internet.';

  @override
  String get wifiConfigurationList => 'Lista de Configuración Wi-Fi';

  @override
  String get chooseNetworkToRepeat =>
      'Elige una red para que el router repita.';

  @override
  String get noNetworksFound =>
      'No se encontraron redes.\nToca actualizar para buscar de nuevo.';

  @override
  String scanFailed(String error) {
    return 'Error en la búsqueda: $error';
  }

  @override
  String connectionFailed(String error) {
    return 'Error en la conexión: $error';
  }

  @override
  String connectedTo(String ssid) {
    return 'Conectado a $ssid';
  }

  @override
  String get enterPasswordFor => 'Ingresa la contraseña para';

  @override
  String get cancel => 'Cancelar';

  @override
  String get connect => 'Conectar';

  @override
  String get scanQrCode => 'Escanear Código QR';

  @override
  String get scanWifiQrCode => 'Escanear Código QR de Wi-Fi';

  @override
  String get toggleFlash => 'Alternar flash';

  @override
  String get pointCameraAtQr => 'Apunta tu cámara a un código QR de Wi-Fi';

  @override
  String get invalidWifiQrCode => 'Código QR de Wi-Fi inválido';

  @override
  String get qrCodeNoValidSsid => 'El código QR no contiene un SSID válido';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get logoutConfirmation => '¿Estás seguro de que deseas cerrar sesión?';

  @override
  String get ok => 'OK';

  @override
  String get retry => 'Reintentar';

  @override
  String get routerUnreachable => 'Router Inaccesible';

  @override
  String get routerUnreachableMessage =>
      'Router inaccesible. Por favor, conéctate a la red del router GL.iNet.';

  @override
  String get authenticationFailed => 'Error de Autenticación';

  @override
  String get storedCredentialsInvalid =>
      'Las credenciales almacenadas son inválidas. Por favor, inicia sesión de nuevo.';

  @override
  String get autoLoginFailed =>
      'Error en el inicio de sesión automático. Por favor, inicia sesión manualmente.';

  @override
  String get loginSuccessful => 'Inicio de sesión exitoso';

  @override
  String get networkError => 'Error de Red';

  @override
  String get loginFailed => 'Error de Inicio de Sesión';

  @override
  String unexpectedError(String error) {
    return 'Ocurrió un error inesperado: $error';
  }

  @override
  String get sessionExpired => 'Sesión Expirada';

  @override
  String get sessionExpiredMessage =>
      'Tu sesión ha expirado. Por favor, inicia sesión de nuevo para continuar.';

  @override
  String get help => 'Ayuda';

  @override
  String get rateTheApp => 'Calificar la App';

  @override
  String get about => 'Acerca de';

  @override
  String get howToUse => 'Cómo Usar';

  @override
  String get gotIt => '¡Entendido!';

  @override
  String get helpStep1Title => '1. Conéctate a Tu Router';

  @override
  String get helpStep1Description =>
      'Asegúrate de que tu teléfono esté conectado a la red WiFi de tu router GL.iNet.';

  @override
  String get helpStep2Title => '2. Inicia Sesión';

  @override
  String get helpStep2Description =>
      'Ingresa la contraseña de administrador de tu router (la misma que usas en la interfaz web).';

  @override
  String get helpStep3Title => '3. Buscar Redes';

  @override
  String get helpStep3Description =>
      'Toca \"Configurar Repetidor Wi-Fi\" para buscar redes WiFi disponibles para repetir.';

  @override
  String get helpStep4Title => '4. Seleccionar y Conectar';

  @override
  String get helpStep4Description =>
      'Elige una red e ingresa su contraseña. Tu router extenderá la cobertura de esa red.';

  @override
  String get helpStep5Title => '5. Verificar Conexión';

  @override
  String get helpStep5Description =>
      'El panel muestra el estado de internet de tu router. ¡Verde significa conectado!';

  @override
  String get aboutDescription =>
      'Configura tu router GL.iNet como repetidor WiFi con facilidad.';

  @override
  String get inAppReviewNotAvailable =>
      'La calificación en la app no está disponible. La página de la tienda se abrirá cuando la app sea publicada.';

  @override
  String get locationPermissionRequired => 'Permiso de Ubicación Requerido';

  @override
  String get locationPermissionMessage =>
      'Para mostrar el nombre de la red WiFi, se necesita permiso de ubicación. Por favor, habilítalo en la configuración de la app.';

  @override
  String get openSettings => 'Abrir Configuración';

  @override
  String get notConnectedToRouter => 'No Conectado al Router';

  @override
  String get notConnectedToRouterMessage =>
      'Por favor, conecta tu dispositivo a la red WiFi de un router GL.iNet para usar esta aplicación.';

  @override
  String get openWifiSettings => 'Abrir Configuración WiFi';

  @override
  String get checkConnection => 'Verificar Conexión';

  @override
  String get checkingRouterConnection => 'Verificando conexión al router...';
}
