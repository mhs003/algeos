echo "Open the power menu on Super+Esc"

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

for part in "$ALGEOS_PATH"/config/niri/*.kdl; do
  deploy "$part" "$HOME/.config/niri/$(basename "$part")"
done

deploy "$ALGEOS_PATH/config/scripts/power-menu" "$HOME/.local/bin/power-menu"
chmod 755 "$HOME/.local/bin/power-menu"
