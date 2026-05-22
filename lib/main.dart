import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'src/app_i18n.dart';
import 'src/app_store_urls.dart';
import 'src/country_flag.dart';
import 'src/models.dart';
import 'src/nordvpn_api.dart';
import 'src/wireguard_profile.dart';

void main() {
  runApp(const NordAccessApp());
}

class NordAccessApp extends StatefulWidget {
  const NordAccessApp({super.key});

  @override
  State<NordAccessApp> createState() => _NordAccessAppState();
}

class _NordAccessAppState extends State<NordAccessApp> {
  late AppLanguage _language;

  @override
  void initState() {
    super.initState();
    _language = appLanguageFromLocale(
      WidgetsBinding.instance.platformDispatcher.locale,
    );
  }

  void _onLanguageChanged(AppLanguage language) {
    setState(() {
      _language = language;
    });
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppI18n(_language);
    return MaterialApp(
      title: i18n.title,
      debugShowCheckedModeBanner: false,
      locale: _language.locale,
      supportedLocales: AppLanguage.values
          .map((language) => language.locale)
          .toList(),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A6D6D),
          brightness: Brightness.light,
        ),
      ),
      home: WireGuardProfilePage(
        language: _language,
        onLanguageChanged: _onLanguageChanged,
      ),
    );
  }
}

class WireGuardProfilePage extends StatefulWidget {
  const WireGuardProfilePage({
    super.key,
    required this.language,
    required this.onLanguageChanged,
  });

  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;

  @override
  State<WireGuardProfilePage> createState() => _WireGuardProfilePageState();
}

class _WireGuardProfilePageState extends State<WireGuardProfilePage> {
  final _tokenController = TextEditingController();
  final _apiClient = NordVpnApiClient();

  static const String _autoCountryCode = '__AUTO__';
  static const double _qrExportSize = 1024;
  static const Map<String, String> _countryNamesJaByCode = <String, String>{
    'AD': 'アンドラ',
    'AE': 'アラブ首長国連邦',
    'AF': 'アフガニスタン',
    'AL': 'アルバニア',
    'AM': 'アルメニア',
    'AO': 'アンゴラ',
    'AR': 'アルゼンチン',
    'AT': 'オーストリア',
    'AU': 'オーストラリア',
    'AZ': 'アゼルバイジャン',
    'BA': 'ボスニア・ヘルツェゴビナ',
    'BD': 'バングラデシュ',
    'BE': 'ベルギー',
    'BG': 'ブルガリア',
    'BH': 'バーレーン',
    'BM': 'バミューダ',
    'BN': 'ブルネイ',
    'BO': 'ボリビア',
    'BR': 'ブラジル',
    'BS': 'バハマ',
    'BT': 'ブータン',
    'BZ': 'ベリーズ',
    'CA': 'カナダ',
    'CH': 'スイス',
    'CL': 'チリ',
    'CO': 'コロンビア',
    'CR': 'コスタリカ',
    'CY': 'キプロス',
    'CZ': 'チェコ',
    'DE': 'ドイツ',
    'DK': 'デンマーク',
    'DO': 'ドミニカ共和国',
    'DZ': 'アルジェリア',
    'EC': 'エクアドル',
    'EE': 'エストニア',
    'EG': 'エジプト',
    'ES': 'スペイン',
    'ET': 'エチオピア',
    'FI': 'フィンランド',
    'FR': 'フランス',
    'GB': 'イギリス',
    'GE': 'ジョージア',
    'GH': 'ガーナ',
    'GL': 'グリーンランド',
    'GR': 'ギリシャ',
    'GT': 'グアテマラ',
    'GU': 'グアム',
    'HK': '香港',
    'HN': 'ホンジュラス',
    'HR': 'クロアチア',
    'HU': 'ハンガリー',
    'ID': 'インドネシア',
    'IE': 'アイルランド',
    'IL': 'イスラエル',
    'IM': 'マン島',
    'IN': 'インド',
    'IQ': 'イラク',
    'IS': 'アイスランド',
    'IT': 'イタリア',
    'JE': 'ジャージー',
    'JM': 'ジャマイカ',
    'JO': 'ヨルダン',
    'JP': '日本',
    'KE': 'ケニア',
    'KH': 'カンボジア',
    'KM': 'コモロ',
    'KR': '韓国',
    'KW': 'クウェート',
    'KY': 'ケイマン諸島',
    'KZ': 'カザフスタン',
    'LA': 'ラオス',
    'LB': 'レバノン',
    'LI': 'リヒテンシュタイン',
    'LK': 'スリランカ',
    'LT': 'リトアニア',
    'LU': 'ルクセンブルク',
    'LV': 'ラトビア',
    'LY': 'リビア',
    'MA': 'モロッコ',
    'MC': 'モナコ',
    'MD': 'モルドバ',
    'ME': 'モンテネグロ',
    'MK': '北マケドニア',
    'MM': 'ミャンマー',
    'MN': 'モンゴル',
    'MR': 'モーリタニア',
    'MT': 'マルタ',
    'MU': 'モーリシャス',
    'MX': 'メキシコ',
    'MY': 'マレーシア',
    'MZ': 'モザンビーク',
    'NG': 'ナイジェリア',
    'NL': 'オランダ',
    'NO': 'ノルウェー',
    'NP': 'ネパール',
    'NZ': 'ニュージーランド',
    'PA': 'パナマ',
    'PE': 'ペルー',
    'PG': 'パプアニューギニア',
    'PH': 'フィリピン',
    'PK': 'パキスタン',
    'PL': 'ポーランド',
    'PR': 'プエルトリコ',
    'PT': 'ポルトガル',
    'PY': 'パラグアイ',
    'QA': 'カタール',
    'RO': 'ルーマニア',
    'RS': 'セルビア',
    'RW': 'ルワンダ',
    'SE': 'スウェーデン',
    'SG': 'シンガポール',
    'SI': 'スロベニア',
    'SK': 'スロバキア',
    'SN': 'セネガル',
    'SO': 'ソマリア',
    'SR': 'スリナム',
    'SV': 'エルサルバドル',
    'TH': 'タイ',
    'TJ': 'タジキスタン',
    'TN': 'チュニジア',
    'TR': 'トルコ',
    'TT': 'トリニダード・トバゴ',
    'TW': '台湾',
    'UA': 'ウクライナ',
    'US': 'アメリカ合衆国',
    'UY': 'ウルグアイ',
    'UZ': 'ウズベキスタン',
    'VE': 'ベネズエラ',
    'VN': 'ベトナム',
    'ZA': '南アフリカ',
  };
  static const Map<String, String> _countryNamesZhByCode = <String, String>{
    'AD': '安道尔',
    'AE': '阿拉伯联合酋长国',
    'AF': '阿富汗',
    'AL': '阿尔巴尼亚',
    'AM': '亚美尼亚',
    'AO': '安哥拉',
    'AR': '阿根廷',
    'AT': '奥地利',
    'AU': '澳大利亚',
    'AZ': '阿塞拜疆',
    'BA': '波斯尼亚和黑塞哥维那',
    'BD': '孟加拉国',
    'BE': '比利时',
    'BG': '保加利亚',
    'BH': '巴林',
    'BM': '百慕大',
    'BN': '文莱',
    'BO': '玻利维亚',
    'BR': '巴西',
    'BS': '巴哈马',
    'BT': '不丹',
    'BZ': '伯利兹',
    'CA': '加拿大',
    'CH': '瑞士',
    'CL': '智利',
    'CO': '哥伦比亚',
    'CR': '哥斯达黎加',
    'CY': '塞浦路斯',
    'CZ': '捷克',
    'DE': '德国',
    'DK': '丹麦',
    'DO': '多米尼加共和国',
    'DZ': '阿尔及利亚',
    'EC': '厄瓜多尔',
    'EE': '爱沙尼亚',
    'EG': '埃及',
    'ES': '西班牙',
    'ET': '埃塞俄比亚',
    'FI': '芬兰',
    'FR': '法国',
    'GB': '英国',
    'GE': '格鲁吉亚',
    'GH': '加纳',
    'GL': '格陵兰',
    'GR': '希腊',
    'GT': '危地马拉',
    'GU': '关岛',
    'HK': '香港',
    'HN': '洪都拉斯',
    'HR': '克罗地亚',
    'HU': '匈牙利',
    'ID': '印度尼西亚',
    'IE': '爱尔兰',
    'IL': '以色列',
    'IM': '马恩岛',
    'IN': '印度',
    'IQ': '伊拉克',
    'IS': '冰岛',
    'IT': '意大利',
    'JE': '泽西岛',
    'JM': '牙买加',
    'JO': '约旦',
    'JP': '日本',
    'KE': '肯尼亚',
    'KH': '柬埔寨',
    'KM': '科摩罗',
    'KR': '韩国',
    'KW': '科威特',
    'KY': '开曼群岛',
    'KZ': '哈萨克斯坦',
    'LA': '老挝',
    'LB': '黎巴嫩',
    'LI': '列支敦士登',
    'LK': '斯里兰卡',
    'LT': '立陶宛',
    'LU': '卢森堡',
    'LV': '拉脱维亚',
    'LY': '利比亚',
    'MA': '摩洛哥',
    'MC': '摩纳哥',
    'MD': '摩尔多瓦',
    'ME': '黑山',
    'MK': '北马其顿',
    'MM': '缅甸',
    'MN': '蒙古',
    'MR': '毛里塔尼亚',
    'MT': '马耳他',
    'MU': '毛里求斯',
    'MX': '墨西哥',
    'MY': '马来西亚',
    'MZ': '莫桑比克',
    'NG': '尼日利亚',
    'NL': '荷兰',
    'NO': '挪威',
    'NP': '尼泊尔',
    'NZ': '新西兰',
    'PA': '巴拿马',
    'PE': '秘鲁',
    'PG': '巴布亚新几内亚',
    'PH': '菲律宾',
    'PK': '巴基斯坦',
    'PL': '波兰',
    'PR': '波多黎各',
    'PT': '葡萄牙',
    'PY': '巴拉圭',
    'QA': '卡塔尔',
    'RO': '罗马尼亚',
    'RS': '塞尔维亚',
    'RW': '卢旺达',
    'SE': '瑞典',
    'SG': '新加坡',
    'SI': '斯洛文尼亚',
    'SK': '斯洛伐克',
    'SN': '塞内加尔',
    'SO': '索马里',
    'SR': '苏里南',
    'SV': '萨尔瓦多',
    'TH': '泰国',
    'TJ': '塔吉克斯坦',
    'TN': '突尼斯',
    'TR': '土耳其',
    'TT': '特立尼达和多巴哥',
    'TW': '台湾',
    'UA': '乌克兰',
    'US': '美国',
    'UY': '乌拉圭',
    'UZ': '乌兹别克斯坦',
    'VE': '委内瑞拉',
    'VN': '越南',
    'ZA': '南非',
  };
  static const Map<String, String> _countryNamesEsByCode = <String, String>{
    'AD': 'Andorra',
    'AE': 'Emiratos Árabes Unidos',
    'AF': 'Afganistán',
    'AL': 'Albania',
    'AM': 'Armenia',
    'AO': 'Angola',
    'AR': 'Argentina',
    'AT': 'Austria',
    'AU': 'Australia',
    'AZ': 'Azerbaiyán',
    'BA': 'Bosnia y Herzegovina',
    'BD': 'Bangladés',
    'BE': 'Bélgica',
    'BG': 'Bulgaria',
    'BH': 'Baréin',
    'BM': 'Bermudas',
    'BN': 'Brunéi',
    'BO': 'Bolivia',
    'BR': 'Brasil',
    'BS': 'Bahamas',
    'BT': 'Bután',
    'BZ': 'Belice',
    'CA': 'Canadá',
    'CH': 'Suiza',
    'CL': 'Chile',
    'CO': 'Colombia',
    'CR': 'Costa Rica',
    'CY': 'Chipre',
    'CZ': 'Chequia',
    'DE': 'Alemania',
    'DK': 'Dinamarca',
    'DO': 'República Dominicana',
    'DZ': 'Argelia',
    'EC': 'Ecuador',
    'EE': 'Estonia',
    'EG': 'Egipto',
    'ES': 'España',
    'ET': 'Etiopía',
    'FI': 'Finlandia',
    'FR': 'Francia',
    'GB': 'Reino Unido',
    'GE': 'Georgia',
    'GH': 'Ghana',
    'GL': 'Groenlandia',
    'GR': 'Grecia',
    'GT': 'Guatemala',
    'GU': 'Guam',
    'HK': 'Hong Kong',
    'HN': 'Honduras',
    'HR': 'Croacia',
    'HU': 'Hungría',
    'ID': 'Indonesia',
    'IE': 'Irlanda',
    'IL': 'Israel',
    'IM': 'Isla de Man',
    'IN': 'India',
    'IQ': 'Irak',
    'IS': 'Islandia',
    'IT': 'Italia',
    'JE': 'Jersey',
    'JM': 'Jamaica',
    'JO': 'Jordania',
    'JP': 'Japón',
    'KE': 'Kenia',
    'KH': 'Camboya',
    'KM': 'Comoras',
    'KR': 'Corea del Sur',
    'KW': 'Kuwait',
    'KY': 'Islas Caimán',
    'KZ': 'Kazajistán',
    'LA': 'Laos',
    'LB': 'Líbano',
    'LI': 'Liechtenstein',
    'LK': 'Sri Lanka',
    'LT': 'Lituania',
    'LU': 'Luxemburgo',
    'LV': 'Letonia',
    'LY': 'Libia',
    'MA': 'Marruecos',
    'MC': 'Mónaco',
    'MD': 'Moldavia',
    'ME': 'Montenegro',
    'MK': 'Macedonia del Norte',
    'MM': 'Myanmar',
    'MN': 'Mongolia',
    'MR': 'Mauritania',
    'MT': 'Malta',
    'MU': 'Mauricio',
    'MX': 'México',
    'MY': 'Malasia',
    'MZ': 'Mozambique',
    'NG': 'Nigeria',
    'NL': 'Países Bajos',
    'NO': 'Noruega',
    'NP': 'Nepal',
    'NZ': 'Nueva Zelanda',
    'PA': 'Panamá',
    'PE': 'Perú',
    'PG': 'Papúa Nueva Guinea',
    'PH': 'Filipinas',
    'PK': 'Pakistán',
    'PL': 'Polonia',
    'PR': 'Puerto Rico',
    'PT': 'Portugal',
    'PY': 'Paraguay',
    'QA': 'Catar',
    'RO': 'Rumanía',
    'RS': 'Serbia',
    'RW': 'Ruanda',
    'SE': 'Suecia',
    'SG': 'Singapur',
    'SI': 'Eslovenia',
    'SK': 'Eslovaquia',
    'SN': 'Senegal',
    'SO': 'Somalia',
    'SR': 'Surinam',
    'SV': 'El Salvador',
    'TH': 'Tailandia',
    'TJ': 'Tayikistán',
    'TN': 'Túnez',
    'TR': 'Turquía',
    'TT': 'Trinidad y Tobago',
    'TW': 'Taiwán',
    'UA': 'Ucrania',
    'US': 'Estados Unidos',
    'UY': 'Uruguay',
    'UZ': 'Uzbekistán',
    'VE': 'Venezuela',
    'VN': 'Vietnam',
    'ZA': 'Sudáfrica',
  };

  bool _isLoading = false;
  bool _isLoadingCountries = false;
  String? _nordLynxPrivateKey;
  String? _generatedConfig;
  Object? _countryLoadError;
  String _selectedCountryCode = _autoCountryCode;
  List<NordCountry> _countries = <NordCountry>[];
  List<NordRecommendedServer> _recommendedServers = <NordRecommendedServer>[];
  NordRecommendedServer? _selectedServer;

  AppI18n get _t => AppI18n(widget.language);

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _apiClient.close();
    super.dispose();
  }

  Future<void> _generate() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      _showMessage(_t.enterAccessToken, isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final credentials = await _apiClient.fetchServiceCredentials(token);
      final servers = await _apiClient.fetchRecommendedWireGuardServers(
        countryCode: _effectiveCountryCode,
        limit: 20,
      );
      final selectedServer = servers.first;

      final config = _buildConfig(
        privateKey: credentials.nordlynxPrivateKey,
        server: selectedServer,
      );

      if (!mounted) {
        return;
      }
      setState(() {
        _nordLynxPrivateKey = credentials.nordlynxPrivateKey;
        _recommendedServers = servers;
        _selectedServer = selectedServer;
        _generatedConfig = config;
      });
      _showMessage(_t.profileGenerated);
    } on NordApiException catch (e) {
      _showMessage(_t.apiErrorMessage(e), isError: true);
    } on FormatException catch (e) {
      _showMessage(_t.responseParseError(e.message), isError: true);
    } catch (e) {
      _showMessage(_t.unexpectedError(e), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    final config = _generatedConfig;
    if (config == null) {
      return;
    }

    final suggestedName = _buildSuggestedFileName();
    final xFile = XFile.fromData(
      Uint8List.fromList(utf8.encode(config)),
      mimeType: 'text/plain',
      name: suggestedName,
    );

    await _saveFile(
      xFile: xFile,
      suggestedName: suggestedName,
      typeGroup: XTypeGroup(
        label: _t.fileTypeLabel,
        extensions: <String>['conf'],
      ),
      errorMessageBuilder: _t.saveFailed,
    );
  }

  Future<void> _saveQrCode() async {
    final config = _generatedConfig;
    if (config == null) {
      return;
    }

    Uint8List imageBytes;
    try {
      imageBytes = await _buildQrPngBytes(config);
    } catch (e) {
      _showMessage(_t.qrSaveFailed(e), isError: true);
      return;
    }

    final suggestedName = _buildSuggestedQrFileName();
    final xFile = XFile.fromData(
      imageBytes,
      mimeType: 'image/png',
      name: suggestedName,
    );

    await _saveFile(
      xFile: xFile,
      suggestedName: suggestedName,
      typeGroup: XTypeGroup(
        label: _t.qrImageTypeLabel,
        extensions: <String>['png'],
      ),
      errorMessageBuilder: _t.qrSaveFailed,
    );
  }

  Future<Uint8List> _buildQrPngBytes(String config) async {
    final painter = QrPainter(
      data: config,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    );
    final imageData = await painter.toImageData(_qrExportSize);
    if (imageData == null) {
      throw StateError('Failed to render QR image data.');
    }
    return imageData.buffer.asUint8List();
  }

  Future<void> _saveFile({
    required XFile xFile,
    required String suggestedName,
    required XTypeGroup typeGroup,
    required String Function(Object error) errorMessageBuilder,
  }) async {
    try {
      final location = await getSaveLocation(
        suggestedName: suggestedName,
        acceptedTypeGroups: <XTypeGroup>[typeGroup],
      );
      if (location == null) {
        return;
      }
      await xFile.saveTo(location.path);
      _showMessage(_t.savedToPath(location.path));
    } on UnimplementedError {
      await _saveFileViaDirectoryPicker(
        xFile: xFile,
        suggestedName: suggestedName,
        errorMessageBuilder: errorMessageBuilder,
      );
    } catch (e) {
      _showMessage(errorMessageBuilder(e), isError: true);
    }
  }

  Future<void> _saveFileViaDirectoryPicker({
    required XFile xFile,
    required String suggestedName,
    required String Function(Object error) errorMessageBuilder,
  }) async {
    try {
      final directoryPath = await getDirectoryPath(
        confirmButtonText: _t.directoryConfirmButton,
      );
      if (directoryPath == null) {
        return;
      }

      final fallbackPath = _buildFilePath(directoryPath, suggestedName);
      await xFile.saveTo(fallbackPath);
      _showMessage(_t.savedToPath(fallbackPath));
    } catch (e) {
      _showMessage(errorMessageBuilder(e), isError: true);
    }
  }

  String _buildFilePath(String directoryPath, String fileName) {
    if (directoryPath.endsWith('/') || directoryPath.endsWith('\\')) {
      return '$directoryPath$fileName';
    }
    final separator = directoryPath.contains('\\') ? '\\' : '/';
    return '$directoryPath$separator$fileName';
  }

  Future<void> _copyProfile() async {
    final config = _generatedConfig;
    if (config == null) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: config));
    _showMessage(_t.copiedToClipboard);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showMessage(_t.couldNotOpenLink, isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  String _buildSuggestedFileName() {
    final hostname = _selectedServer?.hostname ?? 'nordlynx';
    final normalized = hostname.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    return '$normalized.conf';
  }

  String _buildSuggestedQrFileName() {
    final hostname = _selectedServer?.hostname ?? 'nordlynx';
    final normalized = hostname.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    return '${normalized}_qr.png';
  }

  String _buildConfig({
    required String privateKey,
    required NordRecommendedServer server,
  }) {
    return WireGuardProfile.build(
      privateKey: privateKey,
      publicKey: server.publicKey,
      endpointIp: server.station,
      hostname: server.hostname,
    );
  }

  void _onServerChanged(NordRecommendedServer? server) {
    if (server == null || _nordLynxPrivateKey == null) {
      return;
    }

    setState(() {
      _selectedServer = server;
      _generatedConfig = _buildConfig(
        privateKey: _nordLynxPrivateKey!,
        server: server,
      );
    });
  }

  Future<void> _loadCountries() async {
    setState(() {
      _isLoadingCountries = true;
      _countryLoadError = null;
    });

    try {
      final countries = await _apiClient.fetchCountries();
      countries.sort((a, b) => a.code.compareTo(b.code));
      if (!mounted) {
        return;
      }
      setState(() {
        _countries = countries;
      });
    } on NordApiException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _countryLoadError = e;
        _countries = <NordCountry>[];
      });
      _showMessage(_t.countriesUnavailableContinue, isError: true);
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _countryLoadError = e;
        _countries = <NordCountry>[];
      });
      _showMessage(_t.countriesFetchUnexpected, isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCountries = false;
        });
      }
    }
  }

  String? get _effectiveCountryCode {
    if (_selectedCountryCode == _autoCountryCode) {
      return null;
    }
    return _selectedCountryCode;
  }

  String _localizedCountryName(NordCountry country) {
    final fallbackName = country.name.trim();
    final code = country.code;
    return switch (widget.language) {
      AppLanguage.japanese => _countryNamesJaByCode[code] ?? fallbackName,
      AppLanguage.chinese => _countryNamesZhByCode[code] ?? fallbackName,
      AppLanguage.spanish => _countryNamesEsByCode[code] ?? fallbackName,
      AppLanguage.english => fallbackName,
    };
  }

  String _countryLabel(NordCountry country) {
    final localizedName = _localizedCountryName(country);
    return '$localizedName (${country.code})';
  }

  String _serverLabel(NordRecommendedServer server) {
    final label = _t.serverLabel(
      hostname: server.hostname,
      countryCode: server.countryCode,
      countryName: server.countryName,
      load: server.load,
    );
    return '${countryFlagEmoji(server.countryCode)} $label';
  }

  String _countryLoadErrorText() {
    final error = _countryLoadError;
    if (error == null) {
      return '';
    }
    if (error is NordApiException) {
      return _t.apiErrorMessage(error);
    }
    return '$error';
  }

  List<DropdownMenuEntry<String>> _countryEntries() {
    return <DropdownMenuEntry<String>>[
      DropdownMenuEntry<String>(
        value: _autoCountryCode,
        label: _t.countryAutoSelectionLabel,
        leadingIcon: const Icon(Icons.public),
      ),
      ..._countries.map(
        (country) => DropdownMenuEntry<String>(
          value: country.code,
          label: _countryLabel(country),
          leadingIcon: Text(countryFlagEmoji(country.code)),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final t = _t;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFFE6F6F6), Color(0xFFF7FBFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          t.screenTitle,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(t.subtitle),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFFE082)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                t.unofficialDisclaimer,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                t.trademarkNotice,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: const Color(0xFF5D4037)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<AppLanguage>(
                          initialValue: widget.language,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: t.languageLabel,
                          ),
                          items: AppLanguage.values
                              .map(
                                (language) => DropdownMenuItem<AppLanguage>(
                                  value: language,
                                  child: Text(language.nativeName),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            widget.onLanguageChanged(value);
                          },
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _tokenController,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: t.tokenLabel,
                            hintText: t.tokenHint,
                          ),
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return DropdownMenu<String>(
                              width: constraints.maxWidth,
                              enableFilter: true,
                              requestFocusOnTap: true,
                              menuHeight: 340,
                              initialSelection: _selectedCountryCode,
                              hintText: t.countrySearchHint,
                              label: Text(t.countryOptionalLabel),
                              enabled: !_isLoadingCountries && !_isLoading,
                              dropdownMenuEntries: _countryEntries(),
                              onSelected: (value) {
                                if (value == null) {
                                  return;
                                }
                                setState(() {
                                  _selectedCountryCode = value;
                                });
                              },
                            );
                          },
                        ),
                        if (_isLoadingCountries) ...<Widget>[
                          const SizedBox(height: 8),
                          Row(
                            children: <Widget>[
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(t.loadingCountries),
                            ],
                          ),
                        ],
                        if (_countryLoadError != null) ...<Widget>[
                          const SizedBox(height: 8),
                          Text(
                            '${t.countriesLoadFailedPrefix}: ${_countryLoadErrorText()}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: <Widget>[
                            FilledButton.icon(
                              onPressed: _isLoading ? null : _generate,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.play_arrow),
                              label: Text(
                                _isLoading
                                    ? t.generatingButton
                                    : t.generateButton,
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: _generatedConfig == null
                                  ? null
                                  : _saveProfile,
                              icon: const Icon(Icons.save_alt),
                              label: Text(t.saveFileButton),
                            ),
                            OutlinedButton.icon(
                              onPressed: _generatedConfig == null
                                  ? null
                                  : _copyProfile,
                              icon: const Icon(Icons.copy),
                              label: Text(t.copyButton),
                            ),
                          ],
                        ),
                        if (_recommendedServers.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 16),
                          InputDecorator(
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: t.recommendedServersLabel,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<NordRecommendedServer>(
                                value: _selectedServer,
                                isExpanded: true,
                                items: _recommendedServers
                                    .map(
                                      (server) =>
                                          DropdownMenuItem<
                                            NordRecommendedServer
                                          >(
                                            value: server,
                                            child: Text(
                                              _serverLabel(server),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                    )
                                    .toList(),
                                onChanged: _isLoading ? null : _onServerChanged,
                              ),
                            ),
                          ),
                        ],
                        if (_selectedServer != null) ...<Widget>[
                          const SizedBox(height: 16),
                          Text(
                            t.selectedServer(_serverLabel(_selectedServer!)),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B1020),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SelectableText(
                            _generatedConfig ?? t.generatedConfigPlaceholder,
                            style: const TextStyle(
                              color: Color(0xFFE5ECFF),
                              fontFamily: 'monospace',
                              height: 1.45,
                            ),
                          ),
                        ),
                        if (_generatedConfig != null) ...<Widget>[
                          const SizedBox(height: 16),
                          Text(
                            t.wireGuardQrTitle,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFCFD8EA),
                              ),
                            ),
                            child: Column(
                              children: <Widget>[
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 320,
                                  ),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: QrImageView(
                                      data: _generatedConfig!,
                                      version: QrVersions.auto,
                                      errorCorrectionLevel:
                                          QrErrorCorrectLevel.M,
                                      backgroundColor: Colors.white,
                                      padding: const EdgeInsets.all(8),
                                      errorStateBuilder: (context, error) =>
                                          Center(
                                            child: Text(t.qrGenerationFailed),
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  t.qrHelp,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  onPressed: _isLoading ? null : _saveQrCode,
                                  icon: const Icon(Icons.qr_code_2),
                                  label: Text(t.saveQrButton),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: <Widget>[
                            TextButton(
                              onPressed: () =>
                                  _openUrl(AppStoreUrls.privacyPolicy),
                              child: Text(t.privacyPolicyLabel),
                            ),
                            TextButton(
                              onPressed: () => _openUrl(AppStoreUrls.support),
                              child: Text(t.supportLabel),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
