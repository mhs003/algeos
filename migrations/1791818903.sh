echo "Session essentials: clipboard, brightness, polkit agent, notifications, idle lock"

packages=(
  wl-clipboard
  brightnessctl
  hyprpolkitagent
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

deploy() {
  local src=$1 dst=$2

  mkdir -p "$(dirname "$dst")"
  if [[ -e $dst ]] && ! cmp -s "$src" "$dst" && [[ ! -e "$dst.algeos-bak" ]]; then
    cp -a "$dst" "$dst.algeos-bak"
  fi
  cmp -s "$src" "$dst" 2>/dev/null || cp "$src" "$dst"
}

# Notifications (mako already runs as a user service; give it a minimal theme).
deploy "$ALGEOS_PATH/config/mako/config" "$HOME/.config/mako/config"
systemctl --user restart mako.service 2>/dev/null || true

# Idle: lock at 10 min, turn the display off at 15 min.
deploy "$ALGEOS_PATH/config/systemd/user/swayidle.service" "$HOME/.config/systemd/user/swayidle.service"
systemctl --user daemon-reload
systemctl --user enable --now swayidle.service

# Authentication agent, whatever the installed polkit agent names its unit.
# (Parsed in the shell on purpose: piping into `awk`/`grep -m1` closes the
# pipe early, and `pipefail` turns the resulting SIGPIPE into a hard failure.)
unit_files="$(systemctl --user list-unit-files --no-legend 2>/dev/null || true)"
polkit_unit=""
for unit in $unit_files; do
  case $unit in
    *polkit*.service)
      polkit_unit=$unit
      break
      ;;
  esac
done

if [[ -n $polkit_unit ]]; then
  systemctl --user enable --now "$polkit_unit"
fi
