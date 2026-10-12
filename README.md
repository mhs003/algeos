# algeos

Version-controlled setup for a fresh Arch + niri desktop, applied through
migration scripts so a new machine can be brought up from a single clone.

## Usage

```bash
git clone <this-repo> ~/.local/share/algeos
~/.local/share/algeos/install.sh
```

`install.sh` runs every migration in `migrations/` that has not run yet, in
filename order, and records each one that succeeds as a marker under
`${XDG_STATE_HOME:-~/.local/state}/algeos/migrations/`. Re-running it is a
no-op for migrations already applied.

```bash
install.sh --pending   # list migrations that have not run yet (exit 0 if any)
install.sh --refresh   # re-copy everything under config/ onto ~/.config
install.sh --fresh     # clear applied state and re-run everything, overriding
```

Use `--refresh` after editing a file under `config/`: the repo is the source of
truth, so the change lands on `~/.config` without a new migration. (`config/fontconfig`
is excluded — it is installed system-wide by its migration.)

Use `--fresh` to rebuild from scratch. It wipes the run markers, re-runs every
migration with `ALGEOS_FORCE=1` (packages are reinstalled rather than skipped,
configs are overwritten rather than left alone), then re-syncs `config/`.

Migrations run as the current user; steps that need root call `sudo`
themselves. They are written to be idempotent, so a failed or partial run can
simply be repeated.

## Layout

```
install.sh                       entry point; applies pending migrations
migrations/<unix-timestamp>.sh   one-time setup and repair steps
config/                          files the migrations deploy onto the system
```

## Adding a migration

Create `migrations/$(date +%s).sh` with no shebang and mode `0644`. Start it
with an `echo` describing what it does, reference the repo through
`$ALGEOS_PATH`, and make it safe to run more than once.
