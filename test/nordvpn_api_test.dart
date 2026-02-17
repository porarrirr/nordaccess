import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nordacess/src/nordvpn_api.dart';

void main() {
  test('fetchServiceCredentials returns typed error for empty token', () async {
    final api = NordVpnApiClient(
      client: MockClient((request) async => http.Response('ok', 200)),
      baseUrl: 'https://api.nordvpn.com',
    );

    await expectLater(
      api.fetchServiceCredentials('   '),
      throwsA(
        isA<NordApiException>().having(
          (e) => e.code,
          'code',
          NordApiErrorCode.emptyAccessToken,
        ),
      ),
    );
  });

  test('fetchServiceCredentials retries auth header formats', () async {
    final client = MockClient((request) async {
      final auth = request.headers['authorization'];
      if (request.url.path == '/v1/users/services/credentials' &&
          auth == 'Bearer token:test-token') {
        return http.Response(
          jsonEncode(<String, dynamic>{'message': 'unauthorized'}),
          401,
        );
      }

      if (request.url.path == '/v1/users/services/credentials' &&
          auth == 'token:test-token') {
        return http.Response(
          jsonEncode(<String, dynamic>{
            'nordlynx_private_key': 'private-key',
            'username': 'user',
            'password': 'pass',
          }),
          200,
        );
      }

      return http.Response('not found', 404);
    });

    final api = NordVpnApiClient(
      client: client,
      baseUrl: 'https://api.nordvpn.com',
    );

    final credentials = await api.fetchServiceCredentials('test-token');
    expect(credentials.nordlynxPrivateKey, equals('private-key'));
  });

  test('fetchRecommendedWireGuardServer filters by country code', () async {
    var sawCountryLookup = false;
    var sawCountryIdFilter = false;

    final client = MockClient((request) async {
      if (request.url.path == '/v1/servers/countries') {
        sawCountryLookup = true;
        return http.Response(
          jsonEncode(<Map<String, dynamic>>[
            <String, dynamic>{'id': 228, 'code': 'US', 'name': 'United States'},
            <String, dynamic>{'id': 108, 'code': 'JP', 'name': 'Japan'},
          ]),
          200,
        );
      }

      if (request.url.path == '/v1/servers/recommendations') {
        sawCountryIdFilter =
            request.url.queryParameters['filters[country_id]'] == '108' &&
            request.url.queryParameters['limit'] == '1' &&
            request.url.queryParameters['filters[servers_technologies]'] ==
                '35' &&
            request
                    .url
                    .queryParameters['filters[servers_technologies][pivot][status]'] ==
                'online' &&
            request.url.queryParameters['filters[servers.status]'] == 'online';
        return http.Response(
          jsonEncode(<Map<String, dynamic>>[
            <String, dynamic>{
              'id': 1000,
              'hostname': 'jp577.nordvpn.com',
              'station': '20.20.20.20',
              'load': 12,
              'locations': <Map<String, dynamic>>[
                <String, dynamic>{
                  'country': <String, dynamic>{'code': 'JP', 'name': 'Japan'},
                },
              ],
              'technologies': <Map<String, dynamic>>[
                <String, dynamic>{
                  'id': 35,
                  'identifier': 'wireguard_udp',
                  'metadata': <Map<String, dynamic>>[
                    <String, dynamic>{
                      'name': 'public_key',
                      'value': 'jp-public-key',
                    },
                  ],
                },
              ],
            },
          ]),
          200,
        );
      }
      return http.Response('not found', 404);
    });

    final api = NordVpnApiClient(
      client: client,
      baseUrl: 'https://api.nordvpn.com',
    );

    final server = await api.fetchRecommendedWireGuardServer(countryCode: 'jp');
    expect(server.hostname, equals('jp577.nordvpn.com'));
    expect(server.publicKey, equals('jp-public-key'));
    expect(server.station, equals('20.20.20.20'));
    expect(sawCountryLookup, isTrue);
    expect(sawCountryIdFilter, isTrue);
  });

  test('fetchRecommendedWireGuardServers returns multiple servers', () async {
    final client = MockClient((request) async {
      if (request.url.path == '/v1/servers/recommendations') {
        expect(request.url.queryParameters['limit'], equals('20'));
        expect(
          request.url.queryParameters['filters[servers_technologies]'],
          equals('35'),
        );
        expect(
          request
              .url
              .queryParameters['filters[servers_technologies][pivot][status]'],
          equals('online'),
        );
        expect(
          request.url.queryParameters['filters[servers.status]'],
          equals('online'),
        );
        return http.Response(
          jsonEncode(<Map<String, dynamic>>[
            <String, dynamic>{
              'id': 2001,
              'hostname': 'us100.nordvpn.com',
              'station': '10.10.10.10',
              'load': 30,
              'locations': <Map<String, dynamic>>[
                <String, dynamic>{
                  'country': <String, dynamic>{
                    'code': 'US',
                    'name': 'United States',
                  },
                },
              ],
              'technologies': <Map<String, dynamic>>[
                <String, dynamic>{
                  'id': 35,
                  'identifier': 'wireguard_udp',
                  'metadata': <Map<String, dynamic>>[
                    <String, dynamic>{
                      'name': 'public_key',
                      'value': 'us-public-key-1',
                    },
                  ],
                },
              ],
            },
            <String, dynamic>{
              'id': 2002,
              'hostname': 'us101.nordvpn.com',
              'station': '10.10.10.11',
              'load': 31,
              'locations': <Map<String, dynamic>>[
                <String, dynamic>{
                  'country': <String, dynamic>{
                    'code': 'US',
                    'name': 'United States',
                  },
                },
              ],
              'technologies': <Map<String, dynamic>>[
                <String, dynamic>{
                  'id': 35,
                  'identifier': 'wireguard_udp',
                  'metadata': <Map<String, dynamic>>[
                    <String, dynamic>{
                      'name': 'public_key',
                      'value': 'us-public-key-2',
                    },
                  ],
                },
              ],
            },
          ]),
          200,
        );
      }
      return http.Response('not found', 404);
    });

    final api = NordVpnApiClient(
      client: client,
      baseUrl: 'https://api.nordvpn.com',
    );

    final servers = await api.fetchRecommendedWireGuardServers();
    expect(servers, hasLength(2));
    expect(servers.first.hostname, equals('us100.nordvpn.com'));
    expect(servers.last.hostname, equals('us101.nordvpn.com'));
  });

  test('fetchCountries returns normalized countries', () async {
    final client = MockClient((request) async {
      if (request.url.path == '/v1/servers/countries') {
        return http.Response(
          jsonEncode(<Map<String, dynamic>>[
            <String, dynamic>{'id': 108, 'code': 'jp', 'name': 'Japan'},
            <String, dynamic>{'id': 228, 'code': 'US', 'name': 'United States'},
            <String, dynamic>{'id': 999, 'code': '', 'name': 'Broken'},
          ]),
          200,
        );
      }
      return http.Response('not found', 404);
    });

    final api = NordVpnApiClient(
      client: client,
      baseUrl: 'https://api.nordvpn.com',
    );

    final countries = await api.fetchCountries();
    expect(countries, hasLength(2));
    expect(countries.first.code, equals('JP'));
    expect(countries.first.name, equals('Japan'));
    expect(countries.last.code, equals('US'));
  });

  test('fetchCountries throws when response shape is invalid', () async {
    final client = MockClient((request) async {
      if (request.url.path == '/v1/servers/countries') {
        return http.Response(
          jsonEncode(<String, dynamic>{'countries': <dynamic>[]}),
          200,
        );
      }
      return http.Response('not found', 404);
    });

    final api = NordVpnApiClient(
      client: client,
      baseUrl: 'https://api.nordvpn.com',
    );

    await expectLater(api.fetchCountries(), throwsA(isA<NordApiException>()));
  });

  test('fetchCountries throws when all entries are invalid', () async {
    final client = MockClient((request) async {
      if (request.url.path == '/v1/servers/countries') {
        return http.Response(
          jsonEncode(<Map<String, dynamic>>[
            <String, dynamic>{
              'id': null,
              'code': 'US',
              'name': 'United States',
            },
          ]),
          200,
        );
      }
      return http.Response('not found', 404);
    });

    final api = NordVpnApiClient(
      client: client,
      baseUrl: 'https://api.nordvpn.com',
    );

    await expectLater(api.fetchCountries(), throwsA(isA<NordApiException>()));
  });

  test('fetchCountries maps HTTP status to typed error code', () async {
    final client = MockClient((request) async {
      if (request.url.path == '/v1/servers/countries') {
        return http.Response(
          jsonEncode(<String, dynamic>{'message': 'rate limited'}),
          429,
        );
      }
      return http.Response('not found', 404);
    });

    final api = NordVpnApiClient(
      client: client,
      baseUrl: 'https://api.nordvpn.com',
    );

    await expectLater(
      api.fetchCountries(),
      throwsA(
        isA<NordApiException>()
            .having((e) => e.statusCode, 'statusCode', 429)
            .having((e) => e.code, 'code', NordApiErrorCode.tooManyRequests),
      ),
    );
  });
}
