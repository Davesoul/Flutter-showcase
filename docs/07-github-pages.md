# 07 · GitHub Pages deploy

The app is 100% static: no backend, no keys, no server rendering. Any
static host works; this is the Pages setup.

## The one rule: base-href

- **Project site** (`https://<user>.github.io/<repo>/`):
  `flutter build web --release --base-href="/<repo>/"`
- **User site** (`https://<user>.github.io/`): `--base-href="/"` (default)

Wrong base-href = blank page with 404s for `main.dart.js`. If the deploy
is white-screen, check base-href first.

## Workflow (already in `.github/workflows/pages.yml`)

Push to `main` → checkout → `subosito/flutter-action` (pinned 3.38.2) →
`flutter pub get` → `python tool/sync_code_assets.py` (fresh Code-button
sources) → `flutter analyze` → `flutter build web --release
--base-href="/${{ github.event.repository.name }}/"` → upload artifact →
deploy to Pages. Enable Pages in repo Settings → Pages → Source:
"GitHub Actions".

## Local check before pushing

```bash
python tool/sync_code_assets.py
flutter build web --release --base-href="/<repo>/"
cd build/web && python -m http.server 8099
```

Open `http://localhost:8099`, open DevTools console: zero 404s for
`main.dart.js` or `assets/…`, Code buttons load source.

## Custom domain (optional)

Add `CNAME` file with your domain in `web/` (survives rebuilds only if
committed under `web/`), point DNS at GitHub Pages, enforce HTTPS in
Settings → Pages.
