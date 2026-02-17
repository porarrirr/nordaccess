import 'package:flutter_test/flutter_test.dart';
import 'package:nordacess/src/wireguard_profile.dart';

void main() {
  test('build creates expected wireguard profile format', () {
    final profile = WireGuardProfile.build(
      privateKey: 'private-key',
      publicKey: 'public-key',
      endpointIp: '1.2.3.4',
      hostname: 'jp577.nordvpn.com',
    );

    expect(profile, contains('[Interface]'));
    expect(profile, contains('PrivateKey = private-key'));
    expect(profile, contains('Address = 10.5.0.2/16'));
    expect(profile, contains('DNS = 103.86.96.100, 103.86.99.100'));
    expect(profile, contains('[Peer]'));
    expect(profile, contains('PublicKey = public-key'));
    expect(profile, contains('AllowedIPs = 0.0.0.0/0, ::/0'));
    expect(profile, contains('Endpoint = 1.2.3.4:51820'));
    expect(profile, contains('PersistentKeepalive = 25'));
  });
}
