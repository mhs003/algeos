echo "Install the pager, man pages, and the power-menu and mixer UIs"

packages=(
  less
  man-db
  pavucontrol
  btop
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
