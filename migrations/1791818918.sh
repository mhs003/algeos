echo "Taller fuzzel list items, icons only in the app list, even inner padding"

deploy() {
  local src=$1 dst=$2

  mkdir -p "$(dirname "$dst")"
  if [[ -e $dst ]] && ! cmp -s "$src" "$dst" && [[ ! -e "$dst.algeos-bak" ]]; then
    cp -a "$dst" "$dst.algeos-bak"
  fi
  cmp -s "$src" "$dst" 2>/dev/null || cp "$src" "$dst"
}

if ! fuzzel --check-config --config "$ALGEOS_PATH/config/fuzzel/fuzzel.ini" >/dev/null; then
  echo "The fuzzel config in the repo is invalid; refusing to deploy it" >&2
  exit 1
fi

deploy "$ALGEOS_PATH/config/fuzzel/fuzzel.ini" "$HOME/.config/fuzzel/fuzzel.ini"

for script in power-menu power-profile keybinds; do
  deploy "$ALGEOS_PATH/config/scripts/$script" "$HOME/.local/bin/$script"
  chmod 755 "$HOME/.local/bin/$script"
done
