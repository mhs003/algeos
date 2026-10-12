echo "Install the yay AUR helper if it is missing"

if command -v yay >/dev/null 2>&1 && ! (( ${ALGEOS_FORCE:-0} )); then
  echo "yay is already installed; skipping"
  exit 0
fi

# makepkg will not run as root, and it needs git plus the base-devel toolchain
# (which also brings the sudo and fakeroot it uses to install the result).
if ((EUID == 0)); then
  echo "This migration builds a package, so run it as your normal user, not root." >&2
  exit 1
fi

sudo pacman -S --needed --noconfirm base-devel git

build_dir="$(mktemp -d)"
trap 'rm -rf "$build_dir"' EXIT

# yay-bin ships a prebuilt binary, so bootstrapping does not drag in the Go
# toolchain and a source build.
git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$build_dir/yay-bin"
( cd "$build_dir/yay-bin" && makepkg -si --noconfirm )
