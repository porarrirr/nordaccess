# NordAccess

NordVPN Linuxのアクセストークンから、NordLynx (WireGuard) の `.conf` プロファイルを生成して保存するFlutterアプリです。

## 機能

- アクセストークン入力
- UI表示言語切り替え（日本語 / English / 中文 / Español）
- 国一覧を検索して選択（任意）
- 推奨サーバー候補（最大20件）から手動選択
- WireGuardプロファイル文字列を生成
- WireGuard設定のQRコード生成・表示
- QRコード画像 (`.png`) 保存
- `.conf` ファイル保存
- クリップボードコピー

## 使い方

1. NordVPNでアクセストークンを発行する
2. アプリでトークンを入力する
3. 必要なら国を選択する（未選択なら最適国）
4. `プロファイル生成` を押す
5. `ファイル保存` で `.conf` として保存する
6. 必要なら `QR画像保存` で `.png` として保存する
7. 表示されたQRコードをWireGuardアプリで読み取る

## 開発

```bash
flutter pub get
flutter run
```

テスト:

```bash
flutter test
```

## 実装仕様の根拠

- NordVPN Linux公式クライアントのAPIエンドポイント
  - `CredentialsURL = /v1/users/services/credentials`
  - `RecommendedServersURL = /v1/servers/recommendations`
  - `ServersCountriesURL = /v1/servers/countries`
  - https://github.com/NordSecurity/nordvpn-linux/blob/master/core/urls.go
- NordVPN Linux公式クライアントの認証情報レスポンスモデル (`nordlynx_private_key`)
  - https://github.com/NordSecurity/nordvpn-linux/blob/master/core/models.go
- NordVPN Linux公式クライアントのNordLynxデフォルト値
  - `DefaultPrefix = 10.5.0.2/16`
  - `AllowedIPs = 0.0.0.0/0,::/0`
  - `PersistentKeepalive = 25`
  - https://github.com/NordSecurity/nordvpn-linux/blob/master/daemon/vpn/nordlynx/nordlynx.go
  - https://github.com/NordSecurity/nordvpn-linux/blob/master/daemon/vpn/nordlynx/kernel_space.go
- NordVPN公式サポート: Linux向けアクセストークン利用
  - https://support.nordvpn.com/hc/en-us/articles/20286980309265-How-to-use-a-token-with-NordVPN-on-Linux
- WireGuard公式クイックスタート（設定ファイル構文）
  - https://www.wireguard.com/quickstart/

## 注意

- NordVPNの非公開API仕様変更により将来的に動作が変わる可能性があります。
- 生成したトークンと設定ファイルは機密情報として扱ってください。
- 本アプリは Nord Security（NordVPN）の**非公式**ツールです。App Store 提出手順は [docs/APP_STORE.md](docs/APP_STORE.md) を参照してください。
