"""Bundle lib sources as text assets so demo pages can show their code.

Copies <project>/lib/**/*.dart FLAT into <project>/assets/code/ as
`<relative/path/with/__>.dart` (e.g. `src__modules__dashboard_page.dart`).

Why flat? A pubspec `assets:` directory entry only bundles files
DIRECTLY inside it — subdirectories need one entry each. Flat files need
exactly one entry (`assets/code/`) no matter how many sources exist.

Run from the project root (or anywhere — it resolves itself):

    python tool/sync_code_assets.py

The Pages workflow runs this before `flutter build web`, so deploys
always show the current source. Run it locally too after editing code.
"""
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "lib"
DEST = ROOT / "assets" / "code"


def flat_name(dart: Path) -> str:
    return "__".join(dart.relative_to(SRC).parts)


def main() -> int:
    if not SRC.is_dir():
        print(f"lib/ not found under {ROOT}", file=sys.stderr)
        return 1
    if DEST.exists():
        shutil.rmtree(DEST)
    DEST.mkdir(parents=True)
    count = 0
    for dart in SRC.rglob("*.dart"):
        (DEST / flat_name(dart)).write_bytes(dart.read_bytes())
        count += 1
    print(f"synced {count} dart files -> {DEST}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
