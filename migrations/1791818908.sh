echo "Let focus-follows-mouse focus windows that are not fully on screen"

if ! niri validate -c "$ALGEOS_PATH/config/niri/config.kdl" >/dev/null 2>&1; then
  echo "The niri config in the repo is invalid; refusing to deploy it" >&2
  exit 1
fi

mkdir -p "$HOME/.config/niri"
cp "$ALGEOS_PATH/config/niri/config.kdl" "$HOME/.config/niri/config.kdl"
