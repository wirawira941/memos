#!/data/data/com.termux/files/usr/bin/bash
# Install memos (usememos/memos) native Android arm64 build for Termux.
# Source release: https://github.com/wirawira941/memos/releases
set -e

TAG="v0.31.0-termux.2"
VER="0.31.0"
ASSET="memos_${VER}_termux_arm64.tar.gz"
SHA256="3fc7e553974132ba7c77523768c4d5fafd8d7324896e5e2f023f79c26a59e68e"
URL="https://github.com/wirawira941/memos/releases/download/${TAG}/${ASSET}"

if [ -z "$PREFIX" ]; then
  echo "ERROR: \$PREFIX kosong — jalankan di Termux biasa, bukan di dalam proot/chroot." >&2
  exit 1
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
cd "$WORK"

echo "Mengunduh $ASSET ..."
curl -fL --retry 3 -o "$ASSET" "$URL"
echo "Memverifikasi sha256 ..."
echo "${SHA256}  ${ASSET}" | sha256sum -c -

tar xzf "$ASSET"
install -m 0755 memos "$PREFIX/bin/memos"
echo "Terpasang: $PREFIX/bin/memos"

mkdir -p "$HOME/.memos"
cat <<EOF

Selesai. Jalankan Memos dengan:

  memos --data "\$HOME/.memos" --port 8081

Lalu buka http://127.0.0.1:8081 di browser HP.
Data (SQLite) tersimpan di \$HOME/.memos dan tidak ditimpa installer ini.
Tips: pakai 'termux-wake-lock' bila server harus tetap hidup saat layar mati.
EOF

if [ "${SKIP_SMOKE:-0}" != "1" ]; then
  echo "Smoke test (maks 20 detik) ..."
  TMPDATA="$(mktemp -d)"
  "$PREFIX/bin/memos" --data "$TMPDATA" --port 18081 >"$TMPDATA/server.log" 2>&1 &
  PID=$!
  OK=0
  for i in $(seq 1 20); do
    sleep 1
    if curl -fsS -o /dev/null "http://127.0.0.1:18081/"; then OK=1; break; fi
  done
  kill $PID 2>/dev/null || true
  rm -rf "$TMPDATA"
  if [ "$OK" = "1" ]; then
    echo "Smoke test LULUS: server menjawab di port 18081."
  else
    echo "Smoke test GAGAL: server tidak menjawab. Log server:" >&2
    cat "$TMPDATA/server.log" >&2 || true
    exit 1
  fi
fi
