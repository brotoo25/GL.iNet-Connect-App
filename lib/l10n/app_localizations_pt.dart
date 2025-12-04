// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'GL.iNet Connect';

  @override
  String get appName => 'GL.iNet Connect';

  @override
  String get loginTitle => 'Login do Roteador';

  @override
  String get loginSubtitle =>
      'Digite a senha de administrador do seu roteador.';

  @override
  String get adminPassword => 'Senha de Administrador';

  @override
  String get passwordHint => 'Senha';

  @override
  String get showPassword => 'Mostrar senha';

  @override
  String get hidePassword => 'Ocultar senha';

  @override
  String get login => 'Entrar';

  @override
  String get pleaseEnterPassword =>
      'Por favor, digite a senha de administrador';

  @override
  String get dashboard => 'Painel';

  @override
  String get setUpWifiRepeater => 'Configurar Repetidor Wi-Fi';

  @override
  String get lastCheckedJustNow => 'Verificado: agora mesmo';

  @override
  String lastCheckedSecondsAgo(int seconds) {
    return 'Verificado: há $seconds segundos';
  }

  @override
  String get lastCheckedMinuteAgo => 'Verificado: há 1 minuto';

  @override
  String lastCheckedMinutesAgo(int minutes) {
    return 'Verificado: há $minutes minutos';
  }

  @override
  String get lastCheckedHourAgo => 'Verificado: há 1 hora';

  @override
  String lastCheckedHoursAgo(int hours) {
    return 'Verificado: há $hours horas';
  }

  @override
  String get phoneWifi => 'Wi-Fi do Telefone';

  @override
  String get currentlyConnected => 'Conectado Atualmente:';

  @override
  String get notConnected => 'Não Conectado';

  @override
  String get phoneWifiDescription =>
      'Esta é a rede que seu telefone está usando.';

  @override
  String get routerInternetStatus => 'Status de Internet do Roteador';

  @override
  String get routerInternetConnection => 'Conexão de Internet do Roteador';

  @override
  String get checkingConnection => 'Verificando conexão...';

  @override
  String get connected => 'Conectado';

  @override
  String get disconnected => 'Desconectado';

  @override
  String get routerOnlineDescription =>
      'Seu roteador está online e acessando a internet.';

  @override
  String get routerOfflineDescription =>
      'O roteador não está conectado à internet.';

  @override
  String get wifiConfigurationList => 'Lista de Configuração Wi-Fi';

  @override
  String get chooseNetworkToRepeat =>
      'Escolha uma rede para o roteador repetir.';

  @override
  String get noNetworksFound =>
      'Nenhuma rede encontrada.\nToque em atualizar para buscar novamente.';

  @override
  String scanFailed(String error) {
    return 'Falha na busca: $error';
  }

  @override
  String connectionFailed(String error) {
    return 'Falha na conexão: $error';
  }

  @override
  String connectedTo(String ssid) {
    return 'Conectado a $ssid';
  }

  @override
  String get enterPasswordFor => 'Digite a senha para';

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
  String get pointCameraAtQr => 'Aponte sua câmera para um código QR de Wi-Fi';

  @override
  String get invalidWifiQrCode => 'Código QR de Wi-Fi inválido';

  @override
  String get qrCodeNoValidSsid => 'O código QR não contém um SSID válido';

  @override
  String get logout => 'Sair';

  @override
  String get logoutConfirmation => 'Tem certeza que deseja sair?';

  @override
  String get ok => 'OK';

  @override
  String get retry => 'Tentar Novamente';

  @override
  String get routerUnreachable => 'Roteador Inacessível';

  @override
  String get routerUnreachableMessage =>
      'Roteador inacessível. Por favor, conecte-se à rede do roteador GL.iNet.';

  @override
  String get authenticationFailed => 'Falha na Autenticação';

  @override
  String get storedCredentialsInvalid =>
      'Credenciais armazenadas são inválidas. Por favor, faça login novamente.';

  @override
  String get autoLoginFailed =>
      'Falha no login automático. Por favor, faça login manualmente.';

  @override
  String get loginSuccessful => 'Login bem-sucedido';

  @override
  String get networkError => 'Erro de Rede';

  @override
  String get loginFailed => 'Falha no Login';

  @override
  String unexpectedError(String error) {
    return 'Ocorreu um erro inesperado: $error';
  }

  @override
  String get sessionExpired => 'Sessão Expirada';

  @override
  String get sessionExpiredMessage =>
      'Sua sessão expirou. Por favor, faça login novamente para continuar.';

  @override
  String get help => 'Ajuda';

  @override
  String get rateTheApp => 'Avaliar o App';

  @override
  String get about => 'Sobre';

  @override
  String get howToUse => 'Como Usar';

  @override
  String get gotIt => 'Entendi!';

  @override
  String get helpStep1Title => '1. Conecte-se ao Seu Roteador';

  @override
  String get helpStep1Description =>
      'Certifique-se de que seu telefone está conectado à rede WiFi do seu roteador GL.iNet.';

  @override
  String get helpStep2Title => '2. Faça Login';

  @override
  String get helpStep2Description =>
      'Digite a senha de administrador do roteador (a mesma usada na interface web).';

  @override
  String get helpStep3Title => '3. Buscar Redes';

  @override
  String get helpStep3Description =>
      'Toque em \"Configurar Repetidor Wi-Fi\" para buscar redes WiFi disponíveis para repetir.';

  @override
  String get helpStep4Title => '4. Selecionar e Conectar';

  @override
  String get helpStep4Description =>
      'Escolha uma rede e digite sua senha. Seu roteador estenderá a cobertura dessa rede.';

  @override
  String get helpStep5Title => '5. Verificar Conexão';

  @override
  String get helpStep5Description =>
      'O painel mostra o status de internet do seu roteador. Verde significa conectado!';

  @override
  String get aboutDescription =>
      'Configure seu roteador GL.iNet como repetidor WiFi com facilidade.';

  @override
  String get inAppReviewNotAvailable =>
      'Avaliação no app não disponível. A página da loja será aberta quando o app for publicado.';

  @override
  String get locationPermissionRequired =>
      'Permissão de Localização Necessária';

  @override
  String get locationPermissionMessage =>
      'Para exibir o nome da rede WiFi, é necessária permissão de localização. Por favor, habilite nas configurações do app.';

  @override
  String get openSettings => 'Abrir Configurações';
}
