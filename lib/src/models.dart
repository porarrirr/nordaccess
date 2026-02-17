class NordServiceCredentials {
  const NordServiceCredentials({
    required this.nordlynxPrivateKey,
    required this.username,
    required this.password,
  });

  final String nordlynxPrivateKey;
  final String username;
  final String password;

  factory NordServiceCredentials.fromJson(Map<String, dynamic> json) {
    final privateKey = json['nordlynx_private_key'] as String?;
    final username = json['username'] as String?;
    final password = json['password'] as String?;
    if (privateKey == null || privateKey.isEmpty) {
      throw const FormatException('nordlynx_private_key is missing.');
    }
    if (username == null || username.isEmpty) {
      throw const FormatException('username is missing.');
    }
    if (password == null || password.isEmpty) {
      throw const FormatException('password is missing.');
    }

    return NordServiceCredentials(
      nordlynxPrivateKey: privateKey,
      username: username,
      password: password,
    );
  }
}

class NordRecommendedServer {
  const NordRecommendedServer({
    required this.id,
    required this.hostname,
    required this.station,
    required this.publicKey,
    required this.countryCode,
    required this.countryName,
    required this.load,
  });

  final int id;
  final String hostname;
  final String station;
  final String publicKey;
  final String countryCode;
  final String countryName;
  final int load;

  String get label {
    final country = countryCode.isEmpty ? countryName : countryCode;
    return '$hostname ($country, load: $load%)';
  }

  factory NordRecommendedServer.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as num?)?.toInt();
    final hostname = json['hostname'] as String?;
    final station = json['station'] as String?;
    final load = (json['load'] as num?)?.toInt() ?? -1;
    if (id == null) {
      throw const FormatException('id is missing.');
    }
    if (hostname == null || hostname.isEmpty) {
      throw const FormatException('hostname is missing.');
    }
    if (station == null || station.isEmpty) {
      throw const FormatException('station is missing.');
    }

    final technologies = json['technologies'] as List<dynamic>? ?? const [];
    String? publicKey;
    for (final tech in technologies) {
      if (tech is! Map<String, dynamic>) {
        continue;
      }
      final identifier = tech['identifier'] as String?;
      final id = tech['id'];
      if (identifier != 'wireguard_udp' && id != 35) {
        continue;
      }
      final metadata = tech['metadata'] as List<dynamic>? ?? const [];
      for (final item in metadata) {
        if (item is! Map<String, dynamic>) {
          continue;
        }
        if (item['name'] == 'public_key') {
          final value = item['value'] as String?;
          if (value != null && value.isNotEmpty) {
            publicKey = value.trim();
            break;
          }
        }
      }
      if (publicKey != null) {
        break;
      }
    }
    if (publicKey == null || publicKey.isEmpty) {
      throw const FormatException('WireGuard public key is missing.');
    }

    final locations = json['locations'] as List<dynamic>? ?? const [];
    var countryCode = '';
    var countryName = '';
    if (locations.isNotEmpty) {
      final location = locations.first;
      if (location is Map<String, dynamic>) {
        final country = location['country'];
        if (country is Map<String, dynamic>) {
          countryCode = (country['code'] as String? ?? '').toUpperCase();
          countryName = (country['name'] as String? ?? '').trim();
        }
      }
    }

    return NordRecommendedServer(
      id: id,
      hostname: hostname,
      station: station,
      publicKey: publicKey,
      countryCode: countryCode,
      countryName: countryName,
      load: load,
    );
  }
}

class NordCountry {
  const NordCountry({required this.id, required this.code, required this.name});

  final int id;
  final String code;
  final String name;

  factory NordCountry.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as num?)?.toInt();
    final code = (json['code'] as String?)?.trim().toUpperCase();
    final name = (json['name'] as String?)?.trim();
    if (id == null) {
      throw const FormatException('country id is missing.');
    }
    if (code == null || code.isEmpty) {
      throw const FormatException('country code is missing.');
    }
    if (name == null || name.isEmpty) {
      throw const FormatException('country name is missing.');
    }
    return NordCountry(id: id, code: code, name: name);
  }
}
