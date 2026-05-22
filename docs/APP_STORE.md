# App Store 提出チェックリスト（NordAccess）

審査前に、リポジトリ内の `docs/` を HTTPS で公開し（例: GitHub Pages `https://porarrirr.github.io/nordacess/`）、`lib/src/app_store_urls.dart` の URL が実際の公開先と一致していることを確認してください。

## App Store Connect で設定する項目

| 項目 | 推奨値 |
|------|--------|
| カテゴリ | ユーティリティ |
| マーケティング URL | https://porarrirr.github.io/nordacess/ |
| プライバシーポリシー URL | https://porarrirr.github.io/nordacess/privacy.html |
| サポート URL | https://porarrirr.github.io/nordacess/support.html |
| 年齢制限 | 4+（ギャンブル・成人向けコンテンツなし） |
| 輸出コンプライアンス | アプリは標準 HTTPS のみ → **暗号化に該当しない**（Info.plist `ITSAppUsesNonExemptEncryption = false` と一致） |

## App プライバシー（データ収集の申告）

App Store Connect の「App プライバシー」で、少なくとも次を申告してください。

- **連絡先情報・識別子・使用状況データ**: 収集しない
- **その他のユーザーコンテンツ**（アクセストークン）: ユーザーが入力したデータを、プロファイル生成のため **第三者（Nord Security API）へ送信**。開発者サーバーには保存しない。トラッキングに使用しない。

## 審査メモ（Review Notes）に書く例（英語）

```
NordAccess is an unofficial utility (not affiliated with Nord Security).
It does NOT establish a VPN tunnel on iOS. Users paste their own NordVPN
Linux access token; the app calls api.nordvpn.com over HTTPS to build a
WireGuard .conf string and optional QR code for import into the WireGuard app.
No account system, ads, or analytics. Privacy policy: [your URL]
```

## 商標・ガイドライン 5.2.1

- アプリ名・説明で「公式」「NordVPN 公式」と書かない
- アプリ内の免責表示（実装済み）を維持する
- アイコンに NordVPN のロゴを使わない

## ビルド

```bash
cd nordacess
flutter pub get
flutter build ipa --release
```

Xcode で Archive する場合は、Signing & Capabilities で有効な Distribution 証明書と Bundle ID `dev.nordacess.nordacess`（または登録済み ID）を設定してください。

## よくあるリジェクト理由と対策

| 理由 | 対策 |
|------|------|
| プライバシーポリシー URL が無効 | `docs/` を公開し URL を Connect に登録 |
| 5.4 VPN（Network Extension 不足） | 審査メモで「VPN 接続は提供しない」と明記 |
| 5.2.1 商標 | 非公式免責・サポートページの記載を確認 |
| 暗号化の書類 | Connect で「標準暗号のみ／免除不要」を選択 |
