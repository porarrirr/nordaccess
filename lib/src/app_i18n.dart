import 'dart:ui';

import 'nordvpn_api.dart';

enum AppLanguage { japanese, english, chinese, spanish }

AppLanguage appLanguageFromLocale(Locale locale) {
  return switch (locale.languageCode.toLowerCase()) {
    'ja' => AppLanguage.japanese,
    'zh' => AppLanguage.chinese,
    'es' => AppLanguage.spanish,
    _ => AppLanguage.english,
  };
}

extension AppLanguageX on AppLanguage {
  Locale get locale => switch (this) {
    AppLanguage.japanese => const Locale('ja'),
    AppLanguage.english => const Locale('en'),
    AppLanguage.chinese => const Locale('zh'),
    AppLanguage.spanish => const Locale('es'),
  };

  String get nativeName => switch (this) {
    AppLanguage.japanese => '日本語',
    AppLanguage.english => 'English',
    AppLanguage.chinese => '中文',
    AppLanguage.spanish => 'Español',
  };
}

class AppI18n {
  const AppI18n(this.language);

  final AppLanguage language;

  String get title => 'NordAccess';

  String get subtitle => switch (language) {
    AppLanguage.japanese =>
      'Linux用アクセストークンからNordLynx (WireGuard) 設定ファイルを生成します。',
    AppLanguage.english =>
      'Generate NordLynx (WireGuard) profiles from Linux access tokens.',
    AppLanguage.chinese => '使用 Linux 访问令牌生成 NordLynx (WireGuard) 配置文件。',
    AppLanguage.spanish =>
      'Genera perfiles NordLynx (WireGuard) a partir de tokens de acceso de Linux.',
  };

  String get languageLabel => 'language';

  String get tokenLabel => 'NordVPN Access Token';

  String get tokenHint => switch (language) {
    AppLanguage.japanese => '例: nrd_xxxxxxxxxxxxx',
    AppLanguage.english => 'Example: nrd_xxxxxxxxxxxxx',
    AppLanguage.chinese => '示例: nrd_xxxxxxxxxxxxx',
    AppLanguage.spanish => 'Ejemplo: nrd_xxxxxxxxxxxxx',
  };

  String get countrySearchHint => switch (language) {
    AppLanguage.japanese => '国名またはコードで検索 (例: 日本 / JP)',
    AppLanguage.english =>
      'Search by country name or code (example: Japan / JP)',
    AppLanguage.chinese => '按国家名称或代码搜索（示例：日本 / JP）',
    AppLanguage.spanish => 'Buscar por país o código (ejemplo: Japón / JP)',
  };

  String get countryOptionalLabel => switch (language) {
    AppLanguage.japanese => '国 (任意)',
    AppLanguage.english => 'Country (optional)',
    AppLanguage.chinese => '国家（可选）',
    AppLanguage.spanish => 'País (opcional)',
  };

  String get countryAutoSelectionLabel => switch (language) {
    AppLanguage.japanese => '未選択（最適国）',
    AppLanguage.english => 'Not selected (best location)',
    AppLanguage.chinese => '未选择（最佳地区）',
    AppLanguage.spanish => 'Sin seleccionar (mejor ubicación)',
  };

  String get loadingCountries => switch (language) {
    AppLanguage.japanese => '国一覧を読み込み中...',
    AppLanguage.english => 'Loading countries...',
    AppLanguage.chinese => '正在加载国家列表...',
    AppLanguage.spanish => 'Cargando países...',
  };

  String get countriesLoadFailedPrefix => switch (language) {
    AppLanguage.japanese => '国一覧の取得に失敗しました',
    AppLanguage.english => 'Failed to fetch countries',
    AppLanguage.chinese => '获取国家列表失败',
    AppLanguage.spanish => 'Error al obtener la lista de países',
  };

  String get generateButton => switch (language) {
    AppLanguage.japanese => 'プロファイル生成',
    AppLanguage.english => 'Generate profile',
    AppLanguage.chinese => '生成配置文件',
    AppLanguage.spanish => 'Generar perfil',
  };

  String get generatingButton => switch (language) {
    AppLanguage.japanese => '生成中...',
    AppLanguage.english => 'Generating...',
    AppLanguage.chinese => '生成中...',
    AppLanguage.spanish => 'Generando...',
  };

  String get saveFileButton => switch (language) {
    AppLanguage.japanese => 'ファイル保存',
    AppLanguage.english => 'Save file',
    AppLanguage.chinese => '保存文件',
    AppLanguage.spanish => 'Guardar archivo',
  };

  String get saveQrButton => switch (language) {
    AppLanguage.japanese => 'QR画像保存',
    AppLanguage.english => 'Save QR image',
    AppLanguage.chinese => '保存二维码图片',
    AppLanguage.spanish => 'Guardar imagen QR',
  };

  String get copyButton => switch (language) {
    AppLanguage.japanese => 'コピー',
    AppLanguage.english => 'Copy',
    AppLanguage.chinese => '复制',
    AppLanguage.spanish => 'Copiar',
  };

  String get recommendedServersLabel => switch (language) {
    AppLanguage.japanese => '推奨サーバー候補',
    AppLanguage.english => 'Recommended servers',
    AppLanguage.chinese => '推荐服务器',
    AppLanguage.spanish => 'Servidores recomendados',
  };

  String selectedServer(String serverLabel) => switch (language) {
    AppLanguage.japanese => '選択サーバー: $serverLabel',
    AppLanguage.english => 'Selected server: $serverLabel',
    AppLanguage.chinese => '已选择服务器: $serverLabel',
    AppLanguage.spanish => 'Servidor seleccionado: $serverLabel',
  };

  String get generatedConfigPlaceholder => switch (language) {
    AppLanguage.japanese => '# 生成されたWireGuard設定がここに表示されます。',
    AppLanguage.english => '# Generated WireGuard config will appear here.',
    AppLanguage.chinese => '# 生成的 WireGuard 配置将显示在这里。',
    AppLanguage.spanish =>
      '# La configuración WireGuard generada aparecerá aquí.',
  };

  String get wireGuardQrTitle => switch (language) {
    AppLanguage.japanese => 'WireGuard QRコード',
    AppLanguage.english => 'WireGuard QR code',
    AppLanguage.chinese => 'WireGuard 二维码',
    AppLanguage.spanish => 'Código QR de WireGuard',
  };

  String get qrGenerationFailed => switch (language) {
    AppLanguage.japanese => 'QRコードを生成できませんでした。',
    AppLanguage.english => 'Failed to generate QR code.',
    AppLanguage.chinese => '无法生成二维码。',
    AppLanguage.spanish => 'No se pudo generar el código QR.',
  };

  String get qrHelp => switch (language) {
    AppLanguage.japanese => 'WireGuardアプリで「QRコードから追加」を選択して読み取ってください。',
    AppLanguage.english =>
      'Open the WireGuard app and choose "Add from QR code" to scan.',
    AppLanguage.chinese => '在 WireGuard 应用中选择“从二维码添加”并扫描。',
    AppLanguage.spanish =>
      'En la app de WireGuard, selecciona "Agregar desde código QR" y escanéalo.',
  };

  String get fileTypeLabel => switch (language) {
    AppLanguage.japanese => 'WireGuard プロファイル',
    AppLanguage.english => 'WireGuard profile',
    AppLanguage.chinese => 'WireGuard 配置文件',
    AppLanguage.spanish => 'Perfil de WireGuard',
  };

  String get qrImageTypeLabel => switch (language) {
    AppLanguage.japanese => 'QRコード画像',
    AppLanguage.english => 'QR code image',
    AppLanguage.chinese => '二维码图片',
    AppLanguage.spanish => 'Imagen de código QR',
  };

  String get directoryConfirmButton => switch (language) {
    AppLanguage.japanese => 'このフォルダに保存',
    AppLanguage.english => 'Save to this folder',
    AppLanguage.chinese => '保存到此文件夹',
    AppLanguage.spanish => 'Guardar en esta carpeta',
  };

  String get enterAccessToken => switch (language) {
    AppLanguage.japanese => 'アクセストークンを入力してください。',
    AppLanguage.english => 'Please enter an access token.',
    AppLanguage.chinese => '请输入访问令牌。',
    AppLanguage.spanish => 'Introduce un token de acceso.',
  };

  String get profileGenerated => switch (language) {
    AppLanguage.japanese => 'プロファイルを生成しました。',
    AppLanguage.english => 'Profile generated.',
    AppLanguage.chinese => '配置文件已生成。',
    AppLanguage.spanish => 'Perfil generado.',
  };

  String responseParseError(String message) => switch (language) {
    AppLanguage.japanese => 'レスポンス解析エラー: $message',
    AppLanguage.english => 'Response parse error: $message',
    AppLanguage.chinese => '响应解析错误: $message',
    AppLanguage.spanish => 'Error al analizar la respuesta: $message',
  };

  String unexpectedError(Object error) => switch (language) {
    AppLanguage.japanese => '予期しないエラー: $error',
    AppLanguage.english => 'Unexpected error: $error',
    AppLanguage.chinese => '发生意外错误: $error',
    AppLanguage.spanish => 'Error inesperado: $error',
  };

  String savedToPath(String path) => switch (language) {
    AppLanguage.japanese => '保存しました: $path',
    AppLanguage.english => 'Saved: $path',
    AppLanguage.chinese => '已保存: $path',
    AppLanguage.spanish => 'Guardado: $path',
  };

  String saveFailed(Object error) => switch (language) {
    AppLanguage.japanese => '保存に失敗しました: $error',
    AppLanguage.english => 'Save failed: $error',
    AppLanguage.chinese => '保存失败: $error',
    AppLanguage.spanish => 'Error al guardar: $error',
  };

  String qrSaveFailed(Object error) => switch (language) {
    AppLanguage.japanese => 'QR画像の保存に失敗しました: $error',
    AppLanguage.english => 'Failed to save QR image: $error',
    AppLanguage.chinese => '二维码图片保存失败: $error',
    AppLanguage.spanish => 'Error al guardar la imagen QR: $error',
  };

  String get copiedToClipboard => switch (language) {
    AppLanguage.japanese => 'プロファイルをクリップボードにコピーしました。',
    AppLanguage.english => 'Profile copied to clipboard.',
    AppLanguage.chinese => '配置文件已复制到剪贴板。',
    AppLanguage.spanish => 'Perfil copiado al portapapeles.',
  };

  String get countriesUnavailableContinue => switch (language) {
    AppLanguage.japanese => '国一覧を取得できませんでした。国の未選択で続行できます。',
    AppLanguage.english =>
      'Could not fetch countries. You can continue without selecting a country.',
    AppLanguage.chinese => '无法获取国家列表。你可以不选择国家继续。',
    AppLanguage.spanish =>
      'No se pudo obtener la lista de países. Puedes continuar sin elegir país.',
  };

  String get countriesFetchUnexpected => switch (language) {
    AppLanguage.japanese => '国一覧の取得中にエラーが発生しました。',
    AppLanguage.english => 'An error occurred while loading countries.',
    AppLanguage.chinese => '加载国家列表时发生错误。',
    AppLanguage.spanish => 'Ocurrió un error al cargar los países.',
  };

  String get serverLoadLabel => switch (language) {
    AppLanguage.japanese => '負荷',
    AppLanguage.english => 'load',
    AppLanguage.chinese => '负载',
    AppLanguage.spanish => 'carga',
  };

  String serverLabel({
    required String hostname,
    required String countryCode,
    required String countryName,
    required int load,
  }) {
    final country = countryCode.isEmpty ? countryName : countryCode;
    return '$hostname ($country, $serverLoadLabel: $load%)';
  }

  String apiErrorMessage(NordApiException error) {
    if (error.code == null) {
      return error.message;
    }

    return switch (error.code!) {
      NordApiErrorCode.emptyAccessToken => enterAccessToken,
      NordApiErrorCode.invalidCountryCode => switch (language) {
        AppLanguage.japanese => '国コードは2文字の英字で入力してください (例: JP)。',
        AppLanguage.english => 'Country code must be 2 letters (example: JP).',
        AppLanguage.chinese => '国家代码必须是2个字母（示例：JP）。',
        AppLanguage.spanish =>
          'El código de país debe tener 2 letras (ejemplo: JP).',
      },
      NordApiErrorCode.credentialsResponseInvalid => switch (language) {
        AppLanguage.japanese => '認証情報レスポンスを解析できません。',
        AppLanguage.english => 'Failed to parse credentials response.',
        AppLanguage.chinese => '无法解析凭据响应。',
        AppLanguage.spanish =>
          'No se pudo analizar la respuesta de credenciales.',
      },
      NordApiErrorCode.recommendedServersResponseInvalid => switch (language) {
        AppLanguage.japanese => '推奨サーバーのレスポンス形式が不正です。',
        AppLanguage.english => 'Recommended server response format is invalid.',
        AppLanguage.chinese => '推荐服务器响应格式无效。',
        AppLanguage.spanish =>
          'El formato de respuesta de servidores recomendados no es válido.',
      },
      NordApiErrorCode.noRecommendedServers => switch (language) {
        AppLanguage.japanese => '推奨サーバーが見つかりません。',
        AppLanguage.english => 'No recommended servers were found.',
        AppLanguage.chinese => '未找到推荐服务器。',
        AppLanguage.spanish => 'No se encontraron servidores recomendados.',
      },
      NordApiErrorCode.noWireGuardServers => switch (language) {
        AppLanguage.japanese => 'WireGuard公開鍵付きサーバーが見つかりません。',
        AppLanguage.english =>
          'No servers with WireGuard public keys were found.',
        AppLanguage.chinese => '未找到包含 WireGuard 公钥的服务器。',
        AppLanguage.spanish =>
          'No se encontraron servidores con clave pública de WireGuard.',
      },
      NordApiErrorCode.countryCodeNotFound => switch (language) {
        AppLanguage.japanese => '指定した国コードはNordVPN API上で見つかりませんでした。',
        AppLanguage.english => 'The selected country code was not found.',
        AppLanguage.chinese => '未在 NordVPN API 中找到所选国家代码。',
        AppLanguage.spanish =>
          'No se encontró el código de país seleccionado en la API de NordVPN.',
      },
      NordApiErrorCode.countriesResponseInvalid => switch (language) {
        AppLanguage.japanese => '国一覧レスポンス形式が不正です。',
        AppLanguage.english => 'Countries response format is invalid.',
        AppLanguage.chinese => '国家列表响应格式无效。',
        AppLanguage.spanish =>
          'El formato de respuesta de países no es válido.',
      },
      NordApiErrorCode.countriesUnavailable => switch (language) {
        AppLanguage.japanese => '国一覧の取得に失敗しました。',
        AppLanguage.english => 'Failed to fetch countries.',
        AppLanguage.chinese => '获取国家列表失败。',
        AppLanguage.spanish => 'Error al obtener la lista de países.',
      },
      NordApiErrorCode.badRequest => switch (language) {
        AppLanguage.japanese => 'リクエストが不正です。',
        AppLanguage.english => 'Request is invalid.',
        AppLanguage.chinese => '请求无效。',
        AppLanguage.spanish => 'La solicitud no es válida.',
      },
      NordApiErrorCode.unauthorized => switch (language) {
        AppLanguage.japanese => 'アクセストークンが無効か期限切れです。',
        AppLanguage.english => 'Access token is invalid or expired.',
        AppLanguage.chinese => '访问令牌无效或已过期。',
        AppLanguage.spanish => 'El token de acceso es inválido o expiró.',
      },
      NordApiErrorCode.forbidden => switch (language) {
        AppLanguage.japanese => 'このトークンではアクセスできません。',
        AppLanguage.english => 'This token is not allowed to access the API.',
        AppLanguage.chinese => '此令牌无权访问 API。',
        AppLanguage.spanish =>
          'Este token no tiene permiso para acceder a la API.',
      },
      NordApiErrorCode.notFound => switch (language) {
        AppLanguage.japanese => 'APIエンドポイントが見つかりません。',
        AppLanguage.english => 'API endpoint was not found.',
        AppLanguage.chinese => '未找到 API 端点。',
        AppLanguage.spanish => 'No se encontró el endpoint de la API.',
      },
      NordApiErrorCode.unprocessableEntity => switch (language) {
        AppLanguage.japanese => '入力値の形式が不正です。',
        AppLanguage.english => 'Input format is invalid.',
        AppLanguage.chinese => '输入格式无效。',
        AppLanguage.spanish => 'El formato de entrada no es válido.',
      },
      NordApiErrorCode.tooManyRequests => switch (language) {
        AppLanguage.japanese => 'リクエストが多すぎます。時間をおいて再試行してください。',
        AppLanguage.english => 'Too many requests. Try again later.',
        AppLanguage.chinese => '请求过多，请稍后重试。',
        AppLanguage.spanish =>
          'Demasiadas solicitudes. Vuelve a intentarlo más tarde.',
      },
      NordApiErrorCode.requestFailed => switch (language) {
        AppLanguage.japanese => 'NordVPN APIリクエストに失敗しました。',
        AppLanguage.english => 'NordVPN API request failed.',
        AppLanguage.chinese => 'NordVPN API 请求失败。',
        AppLanguage.spanish => 'La solicitud a la API de NordVPN falló.',
      },
    };
  }
}
