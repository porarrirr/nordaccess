import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';

enum NordApiErrorCode {
  emptyAccessToken,
  invalidCountryCode,
  credentialsResponseInvalid,
  recommendedServersResponseInvalid,
  noRecommendedServers,
  noWireGuardServers,
  countryCodeNotFound,
  countriesResponseInvalid,
  countriesUnavailable,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  unprocessableEntity,
  tooManyRequests,
  requestFailed,
}

class NordApiException implements Exception {
  const NordApiException(this.message, {this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final NordApiErrorCode? code;

  @override
  String toString() {
    if (statusCode == null) {
      return message;
    }
    return 'HTTP $statusCode: $message';
  }
}

class NordVpnApiClient {
  NordVpnApiClient({
    http.Client? client,
    String baseUrl = 'https://api.nordvpn.com',
  }) : _client = client ?? http.Client(),
       _baseUrl = baseUrl;

  final http.Client _client;
  final String _baseUrl;
  static final RegExp _countryCodeRegex = RegExp(r'^[A-Za-z]{2}$');
  static const String _wireguardTechnologyId = '35';

  static const List<String> _authHeaderFormats = <String>[
    'Bearer token:%s',
    'token:%s',
    'Bearer %s',
  ];

  Future<NordServiceCredentials> fetchServiceCredentials(
    String accessToken,
  ) async {
    final token = accessToken.trim();
    if (token.isEmpty) {
      throw const NordApiException(
        'Access token is empty.',
        code: NordApiErrorCode.emptyAccessToken,
      );
    }

    final uri = Uri.parse('$_baseUrl/v1/users/services/credentials');
    final response = await _authorizedGet(uri, token);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _errorFromResponse(response);
    }

    final decoded = _decodeJsonObject(response.body);
    try {
      return NordServiceCredentials.fromJson(decoded);
    } on FormatException catch (e) {
      throw NordApiException(
        'Failed to parse credentials response: ${e.message}',
        code: NordApiErrorCode.credentialsResponseInvalid,
      );
    }
  }

  Future<List<NordRecommendedServer>> fetchRecommendedWireGuardServers({
    String? countryCode,
    int limit = 20,
  }) async {
    final normalizedCountry = countryCode?.trim().toUpperCase() ?? '';
    if (normalizedCountry.isNotEmpty &&
        !_countryCodeRegex.hasMatch(normalizedCountry)) {
      throw const NordApiException(
        'Country code must be 2 letters (example: JP).',
        code: NordApiErrorCode.invalidCountryCode,
      );
    }

    int? countryId;
    if (normalizedCountry.isNotEmpty) {
      countryId = await _resolveCountryId(normalizedCountry);
    }

    final uri = Uri.parse('$_baseUrl/v1/servers/recommendations').replace(
      queryParameters: <String, String>{
        'filters[servers.status]': 'online',
        'filters[servers_technologies]': _wireguardTechnologyId,
        'filters[servers_technologies][pivot][status]': 'online',
        'limit': '$limit',
        if (countryId != null) 'filters[country_id]': '$countryId',
      },
    );

    final response = await _client.get(uri, headers: _defaultHeaders());
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _errorFromResponse(response);
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List<dynamic>) {
      throw const NordApiException(
        'Recommended server response format is invalid.',
        code: NordApiErrorCode.recommendedServersResponseInvalid,
      );
    }
    if (decoded.isEmpty) {
      throw const NordApiException(
        'No recommended servers were found.',
        code: NordApiErrorCode.noRecommendedServers,
      );
    }

    final servers = <NordRecommendedServer>[];
    for (final raw in decoded) {
      if (raw is! Map<String, dynamic>) {
        continue;
      }
      try {
        servers.add(NordRecommendedServer.fromJson(raw));
      } on FormatException {
        // Skip records without enough WireGuard metadata.
      }
    }

    if (servers.isEmpty) {
      throw const NordApiException(
        'No servers with WireGuard public keys were found.',
        code: NordApiErrorCode.noWireGuardServers,
      );
    }

    return servers;
  }

  Future<List<NordCountry>> fetchCountries() async {
    return _fetchCountries();
  }

  Future<NordRecommendedServer> fetchRecommendedWireGuardServer({
    String? countryCode,
  }) async {
    final servers = await fetchRecommendedWireGuardServers(
      countryCode: countryCode,
      limit: 1,
    );
    return servers.first;
  }

  Future<int> _resolveCountryId(String countryCode) async {
    final countries = await fetchCountries();
    for (final country in countries) {
      if (country.code == countryCode) {
        return country.id;
      }
    }
    throw NordApiException(
      'Country code ($countryCode) was not found in NordVPN API.',
      code: NordApiErrorCode.countryCodeNotFound,
    );
  }

  Future<List<NordCountry>> _fetchCountries() async {
    final uri = Uri.parse('$_baseUrl/v1/servers/countries');
    final response = await _client.get(uri, headers: _defaultHeaders());
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _errorFromResponse(response);
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List<dynamic>) {
      throw const NordApiException(
        'Countries response format is invalid.',
        code: NordApiErrorCode.countriesResponseInvalid,
      );
    }

    final countries = <NordCountry>[];
    for (final raw in decoded) {
      if (raw is! Map<String, dynamic>) {
        continue;
      }
      try {
        countries.add(NordCountry.fromJson(raw));
      } on FormatException {
        // Skip invalid record.
      }
    }
    if (countries.isEmpty) {
      throw const NordApiException(
        'Failed to fetch countries.',
        code: NordApiErrorCode.countriesUnavailable,
      );
    }
    return countries;
  }

  void close() {
    _client.close();
  }

  Future<http.Response> _authorizedGet(Uri uri, String token) async {
    http.Response? lastResponse;
    for (final authTemplate in _authHeaderFormats) {
      final authValue = authTemplate.replaceFirst('%s', token);
      final headers = _defaultHeaders();
      headers['Authorization'] = authValue;

      final response = await _client.get(uri, headers: headers);
      lastResponse = response;
      if (response.statusCode == 401 || response.statusCode == 403) {
        continue;
      }
      return response;
    }
    return lastResponse!;
  }

  Map<String, String> _defaultHeaders() => <String, String>{
    'Accept': 'application/json',
    'User-Agent': 'nordacess-flutter',
  };

  Map<String, dynamic> _decodeJsonObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object.');
    }
    return decoded;
  }

  NordApiException _errorFromResponse(http.Response response) {
    final code = response.statusCode;
    final (defaultMessage, errorCode) = switch (code) {
      400 => ('Request is invalid.', NordApiErrorCode.badRequest),
      401 => (
        'Access token is invalid or expired.',
        NordApiErrorCode.unauthorized,
      ),
      403 => (
        'This token is not allowed to access the API.',
        NordApiErrorCode.forbidden,
      ),
      404 => ('API endpoint was not found.', NordApiErrorCode.notFound),
      422 => ('Input format is invalid.', NordApiErrorCode.unprocessableEntity),
      429 => (
        'Too many requests. Try again later.',
        NordApiErrorCode.tooManyRequests,
      ),
      _ => ('NordVPN API request failed.', NordApiErrorCode.requestFailed),
    };

    String? apiMessage;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is String && message.trim().isNotEmpty) {
          apiMessage = message.trim();
        }
      }
    } catch (_) {
      // Ignore invalid/non-JSON body.
    }

    return NordApiException(
      apiMessage ?? defaultMessage,
      statusCode: code,
      code: errorCode,
    );
  }
}
