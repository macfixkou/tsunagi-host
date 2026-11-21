#!/bin/sh
# Installs the Tsunagi host (the program you run on the computer you want to reach from your phone).
#   curl -fsSL https://macfixkou.github.io/tsunagi-host/install.sh | sh
set -e
VERSION="v0.1.0"
BASE="https://github.com/macfixkou/tsunagi-host/releases/download/$VERSION"

case "$(uname -s)" in
  Darwin) FILE="tsunagi-macos-universal" ;;
  Linux)
    case "$(uname -m)" in
      x86_64|amd64) FILE="tsunagi-linux-x86_64" ;;
      aarch64|arm64) FILE="tsunagi-linux-arm64" ;;
      *) echo "Unsupported CPU: $(uname -m)"; exit 1 ;;
    esac ;;
  *) echo "Unsupported system: $(uname -s)"; exit 1 ;;
esac

DIR="${TSUNAGI_INSTALL_DIR:-$HOME/.local/bin}"
mkdir -p "$DIR"
TMP="$(mktemp)"
trap 'rm -f "$TMP" "$TMP.sums"' EXIT
echo "Downloading $FILE ($VERSION)..."
curl -fsSL -o "$TMP" "$BASE/$FILE"
curl -fsSL -o "$TMP.sums" "$BASE/SHA256SUMS"

WANT="$(grep " $FILE\$" "$TMP.sums" | cut -d' ' -f1)"
if command -v shasum >/dev/null 2>&1; then GOT="$(shasum -a 256 "$TMP" | cut -d' ' -f1)"
else GOT="$(sha256sum "$TMP" | cut -d' ' -f1)"; fi
if [ -z "$WANT" ] || [ "$WANT" != "$GOT" ]; then
  echo "Checksum mismatch. Nothing was installed."; exit 1
fi

chmod +x "$TMP"
mv "$TMP" "$DIR/tsunagi"
echo "Installed: $DIR/tsunagi"
case ":$PATH:" in
  *":$DIR:"*) echo "Start it with:  tsunagi host" ;;
  *) echo "Start it with:  $DIR/tsunagi host"
     echo "(Add $DIR to your PATH to type just 'tsunagi'.)" ;;
esac
