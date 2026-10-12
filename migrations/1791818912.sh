echo "Split the niri config into included files, title every binding, and drop the bar's brightness module"

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

# The niri config is split across files that include one another, so the whole
# directory is deployed, not just config.kdl.
mkdir -p "$HOME/.config/niri"
for part in "$ALGEOS_PATH"/config/niri/*.kdl; do
  deploy "$part" "$HOME/.config/niri/$(basename "$part")"
done
deploy "$ALGEOS_PATH/config/waybar/config.jsonc" "$HOME/.config/waybar/config.jsonc"
deploy "$ALGEOS_PATH/config/waybar/style.css" "$HOME/.config/waybar/style.css"

deploy "$ALGEOS_PATH/config/scripts/keybinds" "$HOME/.local/bin/keybinds"
chmod 755 "$HOME/.local/bin/keybinds"

systemctl --user restart waybar.service 2>/dev/null || true
