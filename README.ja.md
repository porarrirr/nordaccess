# NordAccess

[English](README.md) | 日本語

NordVPN Linuxのアクセストークンから、NordLynx（WireGuard）設定を生成するFlutterアプリです。推奨サーバーを選び、`.conf` ファイルとして保存したり、QRコードで別の端末へ転送したりできます。

## 主な機能

- 国を検索して選択、またはNordVPNに最適な場所を選択させる
- 最大20件の推奨サーバーから選択
- WireGuard設定を生成
- `.conf` ファイルとして保存
- QRコードの表示とPNG保存
- 生成した設定をクリップボードへコピー
- 英語・日本語・中国語・スペイン語のUI

## 使い方

1. NordVPN Linux用のアクセストークンを発行します。
2. NordAccessへトークンを入力します。
3. 必要に応じて国と推奨サーバーを選びます。
4. プロファイルを生成します。
5. `.conf` を保存するか、WireGuardクライアントでQRコードを読み取ります。

## セキュリティと互換性

アクセストークン、秘密鍵、設定ファイル、QRコードは機密情報です。保存や共有には注意してください。NordAccessは独立した非公式ツールであり、Nord Securityが開発・提供・サポートするものではありません。NordVPN側のサービス変更により、将来動作しなくなる可能性があります。

実装は [NordVPN Linuxクライアント](https://github.com/NordSecurity/nordvpn-linux) で確認できる動作と、標準の [WireGuard設定形式](https://www.wireguard.com/quickstart/) を参考にしています。

## 開発

```bash
flutter pub get
flutter run
flutter test
```

## ライセンス

独自コードはプロプライエタリで、すべての権利を留保します。詳細は [LICENSE](LICENSE) を参照してください。直接依存する第三者コンポーネントのライセンス原文は [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) に保存し、アプリのアセットにも含めています。
