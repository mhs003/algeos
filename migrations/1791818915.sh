echo "Float the bar's tool windows, and open screenshots in an editor from the notification"

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

mkdir -p "$HOME/.config/niri"
for part in "$ALGEOS_PATH"/config/niri/*.kdl; do
  deploy "$part" "$HOME/.config/niri/$(basename "$part")"
done

deploy "$ALGEOS_PATH/config/waybar/config.jsonc" "$HOME/.config/waybar/config.jsonc"
deploy "$ALGEOS_PATH/config/mako/config" "$HOME/.config/mako/config"
deploy "$ALGEOS_PATH/config/satty/config.toml" "$HOME/.config/satty/config.toml"

deploy "$ALGEOS_PATH/config/scripts/screenshot-edit" "$HOME/.local/bin/screenshot-edit"
chmod 755 "$HOME/.local/bin/screenshot-edit"

systemctl --user restart waybar.service 2>/dev/null || true
makoctl reload 2>/dev/null || true

if (( ${ALGEOS_FORCE:-0} )) || ! pacman -Qq satty >/dev/null 2>&1; then
  if ((EUID == 0)); then
    pacman -S --noconfirm satty
  else
    sudo pacman -S --noconfirm satty
  fi
fi
