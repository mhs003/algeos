echo "Add power-profile switching and an internet speed test to the bar"

packages=(
  power-profiles-daemon
  speedtest-cli
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

# The bar's power-profile module talks to this daemon over DBus.
if ((EUID == 0)); then
  systemctl enable --now power-profiles-daemon.service
else
  sudo systemctl enable --now power-profiles-daemon.service
fi

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

mkdir -p "$HOME/.local/bin"
for script in power-profile speed-test speed-meter; do
  deploy "$ALGEOS_PATH/config/scripts/$script" "$HOME/.local/bin/$script"
  chmod 755 "$HOME/.local/bin/$script"
done

systemctl --user restart waybar.service 2>/dev/null || true

# Seed the speed module once, in the background, so its hover panel has
# something to show straight away. Failures are ignored; clicking retries.
speed_cache="${XDG_CACHE_HOME:-$HOME/.cache}/algeos/speed.json"
if [[ ! -s $speed_cache ]]; then
  setsid --fork "$HOME/.local/bin/speed-test" >/dev/null 2>&1 || true
fi
