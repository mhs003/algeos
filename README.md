# algeos

My Arch + niri desktop, kept as ordered migrations so a fresh machine reaches
the same state from one clone.

## Setup

```bash
git clone git@github.com:mhs003/algeos.git ~/.local/share/algeos
~/.local/share/algeos/install.sh
```

`install.sh` runs every migration that has not run yet, in filename order, and
records each one.

```bash
install.sh --pending   # what has not run yet
install.sh --refresh   # re-copy config/ onto ~/.config
install.sh --fresh     # clear state and re-run everything, overriding
```
