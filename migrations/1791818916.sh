echo "Move columns with Mod+Shift+Left/Right, and put monitor focus on Mod+Alt"

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
