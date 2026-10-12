#!/bin/bash

set -euo pipefail

ALGEOS_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ALGEOS_PATH

MIGRATIONS_DIR="$ALGEOS_PATH/migrations"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/algeos/migrations"

usage() {
  echo "Usage: install.sh [--pending|--refresh|--fresh]"
}

mode=run
force=0
while (($#)); do
  case $1 in
    --pending|--check)
      mode=pending
      ;;
    --refresh)
      mode=refresh
      ;;
    --fresh)
      mode=run
      force=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

migration_files() {
  local file

  [[ -d $MIGRATIONS_DIR ]] || return 0

  for file in "$MIGRATIONS_DIR"/*.sh; do
    [[ -f $file ]] || continue
    printf '%s\n' "$file"
  done
}

pending_files() {
  local file

  while IFS= read -r file; do
    [[ -n $file ]] || continue
    [[ -f "$STATE_DIR/$(basename "$file")" ]] || printf '%s\n' "$file"
  done < <(migration_files)
}

# Re-copy every user config in the repo onto ~/.config, so a change to a file
# under config/ applies without writing a new migration. config/fontconfig is
# excluded because it is installed system-wide by its own migration.
refresh_config() {
  local name src dst

  for src in "$ALGEOS_PATH"/config/*; do
    [[ -d $src ]] || continue
    name="$(basename "$src")"
    [[ $name == fontconfig ]] && continue

    dst="$HOME/.config/$name"
    mkdir -p "$dst"
    cp -R "$src"/. "$dst"/
  done

  systemctl --user daemon-reload 2>/dev/null || true
}

if [[ $mode == pending ]]; then
  pending_output="$(pending_files)"
  if [[ -n $pending_output ]]; then
    printf '%s\n' "${pending_output//$MIGRATIONS_DIR\//}"
    exit 0
  else
    exit 1
  fi
fi

if [[ $mode == refresh ]]; then
  refresh_config
  echo "Refreshed ~/.config from config/"
  exit 0
fi

# --fresh: forget what has been applied and re-run everything, overriding what
# is already there. Migrations see ALGEOS_FORCE and stop skipping existing state.
if (( force )); then
  export ALGEOS_FORCE=1
  rm -rf "$STATE_DIR"
  echo "Fresh install: clearing applied state and re-running every migration"
fi

wait_for_pacman_transaction() {
  local lock_file=/var/lib/pacman/db.lck

  [[ -e $lock_file ]] || return 0
  echo "Waiting for the pacman transaction to finish..."

  while [[ -e $lock_file ]]; do
    sleep 1
  done
}

wait_for_pacman_transaction

mkdir -p "$STATE_DIR"
[[ -d $MIGRATIONS_DIR ]] || exit 0

while IFS= read -r file; do
  [[ -n $file ]] || continue

  marker="$STATE_DIR/$(basename "$file")"
  [[ -f $marker ]] && continue

  echo -e "\e[32m\nRunning migration $(basename "${file%.sh}")\e[0m"
  ALGEOS_PATH="$ALGEOS_PATH" bash -euo pipefail "$file"
  touch "$marker"
done < <(migration_files)

if (( force )); then
  refresh_config
fi

echo
echo "All migrations applied."
