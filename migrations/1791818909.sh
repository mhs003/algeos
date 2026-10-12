echo "Force dark mode across the desktop"

# The single switch that libadwaita and GTK4 applications follow, and that also
# drives Chromium's prefers-color-scheme.
if command -v gsettings >/dev/null 2>&1; then
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
else
  echo "gsettings is missing; relying on the GTK settings files alone" >&2
fi

deploy() {
  local src=$1 dst=$2

  mkdir -p "$(dirname "$dst")"
  if [[ -e $dst ]] && ! cmp -s "$src" "$dst" && [[ ! -e "$dst.algeos-bak" ]]; then
    cp -a "$dst" "$dst.algeos-bak"
  fi
  cmp -s "$src" "$dst" 2>/dev/null || cp "$src" "$dst"
}

# GTK3 does not read color-scheme, so it needs the flag in its own settings.
deploy "$ALGEOS_PATH/config/gtk-3.0/settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
deploy "$ALGEOS_PATH/config/gtk-4.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"
