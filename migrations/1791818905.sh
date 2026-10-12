echo "Tighten the layout, restyle the focus ring, and add a background"

# The niri config is the repo's to own. Validate the repo copy before it goes
# anywhere near the live one.
if ! niri validate -c "$ALGEOS_PATH/config/niri/config.kdl" >/dev/null 2>&1; then
  echo "The niri config in the repo is invalid; refusing to deploy it" >&2
  exit 1
fi
mkdir -p "$HOME/.config/niri"
cp "$ALGEOS_PATH/config/niri/config.kdl" "$HOME/.config/niri/config.kdl"

# A subtle dark vertical gradient, generated here so the repo stays free of
# image blobs. Regenerated only when missing.
wallpaper="$HOME/.local/share/wallpapers/algeos.png"
if [[ ! -f $wallpaper ]]; then
  mkdir -p "$(dirname "$wallpaper")"
  python3 - "$wallpaper" <<'PY'
import struct
import sys
import zlib

width, height = 16, 256
top, bottom = (14, 14, 18), (27, 27, 36)

rows = bytearray()
for y in range(height):
    t = y / (height - 1)
    pixel = bytes(round(top[i] + (bottom[i] - top[i]) * t) for i in range(3))
    rows += b"\x00" + pixel * width


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

deploy() {
  local src=$1 dst=$2

  mkdir -p "$(dirname "$dst")"
  if [[ -e $dst ]] && ! cmp -s "$src" "$dst" && [[ ! -e "$dst.algeos-bak" ]]; then
    cp -a "$dst" "$dst.algeos-bak"
  fi
  cmp -s "$src" "$dst" 2>/dev/null || cp "$src" "$dst"
}

deploy "$ALGEOS_PATH/config/systemd/user/swaybg.service" "$HOME/.config/systemd/user/swaybg.service"
systemctl --user daemon-reload
systemctl --user enable --now swaybg.service
