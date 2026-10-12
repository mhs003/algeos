echo "Configure the terminal and the launcher"

deploy() {
  local src=$1 dst=$2

  mkdir -p "$(dirname "$dst")"
  if [[ -e $dst ]] && ! cmp -s "$src" "$dst" && [[ ! -e "$dst.algeos-bak" ]]; then
    cp -a "$dst" "$dst.algeos-bak"
  fi
  cmp -s "$src" "$dst" 2>/dev/null || cp "$src" "$dst"
}

deploy "$ALGEOS_PATH/config/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
deploy "$ALGEOS_PATH/config/fuzzel/fuzzel.ini" "$HOME/.config/fuzzel/fuzzel.ini"
