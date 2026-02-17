import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'src/app_i18n.dart';
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
    'AE': 'アラブ首長国連邦',
    'AL': 'アルバニア',
    'AR': 'アルゼンチン',
    'AT': 'オーストリア',
    'AU': 'オーストラリア',
    'BA': 'ボスニア・ヘルツェゴビナ',
    'BE': 'ベルギー',
    'BG': 'ブルガリア',
    'BR': 'ブラジル',
    'CA': 'カナダ',
    'CH': 'スイス',
    'CL': 'チリ',
    'CO': 'コロンビア',
    'CR': 'コスタリカ',
    'CY': 'キプロス',
    'CZ': 'チェコ',
    'DE': 'ドイツ',
    'DK': 'デンマーク',
    'EE': 'エストニア',
    'ES': 'スペイン',
    'FI': 'フィンランド',
    'FR': 'フランス',
    'GB': 'イギリス',
    'GE': 'ジョージア',
    'GR': 'ギリシャ',
    'HK': '香港',
    'HR': 'クロアチア',
    'HU': 'ハンガリー',
    'ID': 'インドネシア',
    'IE': 'アイルランド',
    'IL': 'イスラエル',
    'IN': 'インド',
    'IS': 'アイスランド',
    'IT': 'イタリア',
    'JP': '日本',
    'KR': '韓国',
    'LT': 'リトアニア',
    'LU': 'ルクセンブルク',
    'LV': 'ラトビア',
    'MD': 'モルドバ',
    'ME': 'モンテネグロ',
    'MK': '北マケドニア',
    'MX': 'メキシコ',
    'MY': 'マレーシア',
    'NL': 'オランダ',
    'NO': 'ノルウェー',
    'NZ': 'ニュージーランド',
    'PH': 'フィリピン',
    'PL': 'ポーランド',
    'PT': 'ポルトガル',
    'RO': 'ルーマニア',
    'RS': 'セルビア',
    'SE': 'スウェーデン',
    'SG': 'シンガポール',
    'SI': 'スロベニア',
    'SK': 'スロバキア',
    'TH': 'タイ',
    'TR': 'トルコ',
    'TW': '台湾',
    'UA': 'ウクライナ',
    'US': 'アメリカ合衆国',
    'VN': 'ベトナム',
    'ZA': '南アフリカ',
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

  String _countryLabel(NordCountry country) {
    final localizedName = widget.language == AppLanguage.japanese
        ? (_countryNamesJaByCode[country.code] ?? country.name.trim())
        : country.name.trim();
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
                          'NordVPN Access Token -> WireGuard Profile',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(t.subtitle),
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
                            labelText: 'NordVPN Access Token',
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
