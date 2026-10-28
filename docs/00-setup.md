# 00 · Setup from zero (Windows)

Mirror of the in-app **Foundations → Setup** page, with the details that
don't fit on cards. Goal: `flutter doctor` green, a throwaway app running
in Chrome, then Prism UI open.

## 1. Install the SDK

- **winget:** `winget install --id=Google.Flutter -e`
- **manual:** download the zip from docs.flutter.dev, unzip to
  `C:\src\flutter` (no spaces in the path — `Program Files` breaks
  tooling), add `C:\src\flutter\bin` to your **user** PATH.
- Close and reopen every terminal afterwards. Verify: `flutter --version`.

## 2. flutter doctor

Run `flutter doctor`. For web-only work you need green on: Flutter,
Chrome. Android Studio / SDK is optional — only install it if you want a
phone emulator. Fix whatever doctor names; it tells you the command.

## 3. Editor

VS Code + the **Flutter** extension (pulls in **Dart** automatically).
You get: run targets in the status bar, hot reload on save, widget
guides, and `flutter analyze` problems inline. Any editor works — the
extensions are the point.

## 4. Your first throwaway app

```bash
flutter config --enable-web
flutter create hello_first
cd hello_first
flutter run -d chrome
```

Change the counter text, save, watch the browser update in under a
second. That loop — edit, save, see — is 90% of Flutter development.

## 5. Open Prism UI

```bash
cd D:\Coding\flutter-prism-lab
flutter pub get
python tool/sync_code_assets.py
flutter run -d chrome
```

## Troubleshooting

| Symptom | Fix |
|---|---|
| `flutter` not recognized | PATH did not apply: close ALL terminals and VS Code, reopen |
| Red X on Android | Ignore for web-only; install Android Studio if you need emulators |
| `pub get` fails | `flutter clean` + retry; first run needs internet (packages cache) |
| Wrong fonts offline | Run once online — Google Fonts cache, then work offline |
| Blank white Pages deploy | Wrong `--base-href` — see 07-github-pages.md |
| Code button shows an error | Re-run the sync script, then rebuild |

Next: 01-getting-started, then the in-app Dart 101 page.
