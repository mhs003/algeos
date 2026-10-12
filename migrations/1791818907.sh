echo "Text-only bar, softer corners, mouse-follow focus, and a power menu"

deploy() {
  local src=$1 dst=$2

  mkdir -p "$(dirname "$dst")"
  if [[ -e $dst ]] && ! cmp -s "$src" "$dst" && [[ ! -e "$dst.algeos-bak" ]]; then
    cp -a "$dst" "$dst.algeos-bak"
  fi
  cmp -s "$src" "$dst" 2>/dev/null || cp "$src" "$dst"
}

if ! niri validate -c "$ALGEOS_PATH/config/niri/config.kdl" >/dev/null 2>&1; then
  echo "The niri config in the repo is invalid; refusing to deploy it" >&2
  exit 1
fi

deploy "$ALGEOS_PATH/config/niri/config.kdl" "$HOME/.config/niri/config.kdl"
deploy "$ALGEOS_PATH/config/waybar/config.jsonc" "$HOME/.config/waybar/config.jsonc"
deploy "$ALGEOS_PATH/config/waybar/style.css" "$HOME/.config/waybar/style.css"
deploy "$ALGEOS_PATH/config/fuzzel/fuzzel.ini" "$HOME/.config/fuzzel/fuzzel.ini"

deploy "$ALGEOS_PATH/config/scripts/power-menu" "$HOME/.local/bin/power-menu"
chmod 755 "$HOME/.local/bin/power-menu"

systemctl --user restart waybar.service 2>/dev/null || true
