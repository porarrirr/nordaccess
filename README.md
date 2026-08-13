# NordAccess

English | [日本語](README.ja.md)

A Flutter app that creates NordLynx (WireGuard) configuration profiles from a NordVPN Linux access token. It helps you choose a recommended server, export a `.conf` file, or transfer the profile to another device with a QR code.

## Features

- Search and select a country, or let NordVPN choose the best location
- Choose from up to 20 recommended servers
- Generate a WireGuard configuration
- Save the profile as a `.conf` file
- Display and save a QR code as PNG
- Copy the generated configuration to the clipboard
- App interface in English, Japanese, Chinese, and Spanish

## Usage

1. Create an access token for NordVPN on Linux.
2. Enter the token in NordAccess.
3. Optionally choose a country and recommended server.
4. Generate the profile.
5. Save the `.conf` file or scan the displayed QR code with a WireGuard client.

## Security and compatibility

Access tokens, private keys, configuration files, and QR codes are sensitive credentials. Store and share them carefully. NordAccess is an independent, unofficial tool and is not made or supported by Nord Security. Changes to NordVPN's service may affect compatibility.

The implementation follows behavior documented in the [NordVPN Linux client](https://github.com/NordSecurity/nordvpn-linux) and the standard [WireGuard configuration format](https://www.wireguard.com/quickstart/).

## Development

```bash
flutter pub get
flutter run
flutter test
```

## License

The original code is proprietary and all rights are reserved. See [LICENSE](LICENSE). Direct dependency licenses are preserved in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md), which is also included as an application asset.
