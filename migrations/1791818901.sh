echo "Configure the bar: niri modules, minimal style, and run it as a service"

deploy() {
  local src=$1 dst=$2

  mkdir -p "$(dirname "$dst")"
  if [[ -e $dst ]] && ! cmp -s "$src" "$dst" && [[ ! -e "$dst.algeos-bak" ]]; then
    cp -a "$dst" "$dst.algeos-bak"
  fi
  cmp -s "$src" "$dst" 2>/dev/null || cp "$src" "$dst"
}

deploy "$ALGEOS_PATH/config/waybar/config.jsonc" "$HOME/.config/waybar/config.jsonc"
deploy "$ALGEOS_PATH/config/waybar/style.css" "$HOME/.config/waybar/style.css"

# The bar is supervised as a systemd user service now, so niri must not also
# spawn it (that would start a second bar). Comment out the stock line.
niri_config="$HOME/.config/niri/config.kdl"
if [[ -f $niri_config ]] && grep -q '^spawn-at-startup "waybar"$' "$niri_config"; then
  [[ -e "$niri_config.algeos-bak" ]] || cp -a "$niri_config" "$niri_config.algeos-bak"
  sed -i 's|^spawn-at-startup "waybar"$|// spawn-at-startup "waybar"  (started by waybar.service)|' "$niri_config"
fi

# Replace any instance that niri spawned with the supervised one.
pkill -x waybar 2>/dev/null || true
systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP 2>/dev/null || true
systemctl --user enable --now waybar.service
