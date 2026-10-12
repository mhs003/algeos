echo "Install fonts (Noto incl. Bengali, Nerd Font, Font Awesome) and the font defaults"

packages=(
  fontconfig
  ttf-liberation
  noto-fonts
  noto-fonts-emoji
  ttf-jetbrains-mono-nerd
  woff2-font-awesome
)

targets=()
if (( ${ALGEOS_FORCE:-0} )); then
  targets=( "${packages[@]}" )
else
  for package in "${packages[@]}"; do
    pacman -Qq "$package" >/dev/null 2>&1 || targets+=("$package")
  done
fi

if [[ ${#targets[@]} -gt 0 ]]; then
  if ((EUID == 0)); then
    pacman -S --noconfirm "${targets[@]}"
  else
    sudo pacman -S --noconfirm "${targets[@]}"
  fi
fi

# The font defaults are package-owned, like the rest of fontconfig: the file
# lives in conf.avail and /etc/fonts/conf.d links to it. Every application
# (bar, launcher, terminal, browser, GTK/Qt) then resolves non-Latin scripts,
# Nerd Font glyphs and emoji without any per-app configuration.
source_conf="$ALGEOS_PATH/config/fontconfig/50-algeos.conf"
avail_conf=/usr/share/fontconfig/conf.avail/50-algeos.conf
enabled_conf=/etc/fonts/conf.d/50-algeos.conf

if ! cmp -s "$source_conf" "$avail_conf" 2>/dev/null || [[ ! -e $enabled_conf ]]; then
  if ((EUID == 0)); then
    install -Dm644 "$source_conf" "$avail_conf"
    ln -sfn "$avail_conf" "$enabled_conf"
  else
    sudo install -Dm644 "$source_conf" "$avail_conf"
    sudo ln -sfn "$avail_conf" "$enabled_conf"
  fi
fi

fc-cache -f >/dev/null
