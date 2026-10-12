echo "Give the lock screen a background and a themed indicator"

deploy() {
  local src=$1 dst=$2

  mkdir -p "$(dirname "$dst")"
  if [[ -e $dst ]] && ! cmp -s "$src" "$dst" && [[ ! -e "$dst.algeos-bak" ]]; then
    cp -a "$dst" "$dst.algeos-bak"
  fi
  cmp -s "$src" "$dst" 2>/dev/null || cp "$src" "$dst"
}

# A dark panel with a soft accent glow behind the lock indicator, generated
# here so the repo stays free of image blobs.
wallpaper="$HOME/.local/share/wallpapers/lock.png"
if [[ ! -f $wallpaper ]]; then
  mkdir -p "$(dirname "$wallpaper")"
  python3 - "$wallpaper" <<'PY'
import math
import struct
import sys
import zlib

width, height = 480, 270
base = (17, 17, 24)
glow = (38, 50, 78)
cx, cy = width * 0.5, height * 0.40
radius = max(width, height) * 0.62

rows = bytearray()
for y in range(height):
    rows += b"\x00"
    for x in range(width):
        falloff = max(0.0, 1.0 - math.hypot(x - cx, y - cy) / radius) ** 2
        rows += bytes(round(base[i] + (glow[i] - base[i]) * falloff) for i in range(3))


def chunk(kind, data):
    return (
        struct.pack(">I", len(data))
        + kind
        + data
        + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)
    )


png = b"\x89PNG\r\n\x1a\n"
png += chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0))
png += chunk(b"IDAT", zlib.compress(bytes(rows), 9))
png += chunk(b"IEND", b"")

with open(sys.argv[1], "wb") as f:
    f.write(png)
PY
fi

if ! niri validate -c "$ALGEOS_PATH/config/niri/config.kdl" >/dev/null 2>&1; then
  echo "The niri config in the repo is invalid; refusing to deploy it" >&2
  exit 1
fi

for part in "$ALGEOS_PATH"/config/niri/*.kdl; do
  deploy "$part" "$HOME/.config/niri/$(basename "$part")"
done

deploy "$ALGEOS_PATH/config/swaylock/config" "$HOME/.config/swaylock/config"

deploy "$ALGEOS_PATH/config/scripts/lock" "$HOME/.local/bin/lock"
chmod 755 "$HOME/.local/bin/lock"
