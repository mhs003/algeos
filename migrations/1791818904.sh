echo "Deploy the keyboard-oriented niri config"

niri_config="$HOME/.config/niri/config.kdl"
source_config="$ALGEOS_PATH/config/niri/config.kdl"
marker="managed by algeos"

if ! niri validate -c "$source_config" >/dev/null 2>&1; then
  echo "The niri config in the repo is invalid; refusing to deploy it" >&2
  exit 1
fi

# Deploy once. If the target already carries our marker it may hold local
# edits, so leave it alone; otherwise back it up and replace it.
if (( ${ALGEOS_FORCE:-0} )) || [[ ! -f $niri_config ]] || ! grep -qF "$marker" "$niri_config"; then
  if [[ -f $niri_config && ! -e "$niri_config.algeos-bak" ]]; then
    cp -a "$niri_config" "$niri_config.algeos-bak"
  fi
  cp "$source_config" "$niri_config"
fi

if ! niri validate -c "$niri_config" >/dev/null 2>&1; then
  echo "niri rejected the deployed config; restoring the backup" >&2
  [[ -f "$niri_config.algeos-bak" ]] && cp -a "$niri_config.algeos-bak" "$niri_config"
  exit 1
fi
