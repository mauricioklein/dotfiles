# Dotfiles

A small, mise-powered dotfiles setup for macOS. It manages shell configuration,
shared Git/editor settings, CLI tools, and generated shell integrations. The
checkout can live anywhere.

## Setup

Prerequisites: Git and a terminal. `bootstrap.sh` installs mise when needed;
mise installs the declared tools and bootstrap packages.

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

The bootstrap preserves an existing Git identity in the private
`~/.gitconfig.local` file. It does not put identity values in the repository.

## Daily commands

```bash
mise run check             # read-only health check
mise run repair            # apply declared state and regenerate artifacts
mise run update:preview    # preview eligible updates
mise run update            # apply approved policy-safe updates
exec zsh
/usr/bin/time -p zsh -i -c exit
```

Run `mise run update:preview` before `mise run update`. Updates respect the
2-day release hold in `mise.toml`; changing an exact or major selector is a
separate reviewed edit.

For Homebrew-owned packages that mise leaves unchanged, and packages not
tracked by mise:

```bash
mise run brew:upgrade:unmanaged:preview
mise run brew:upgrade:unmanaged
```

The preview runs `brew upgrade -g --dry-run`; the upgrade task runs
`brew upgrade -g && brew cleanup`. Cleanup removes old Homebrew versions and
stale downloads, not arbitrary untracked files, and runs only if the upgrade
succeeds. These tasks cover **all installed Homebrew packages**, including
self-updating casks and packages declared in mise; they do not filter out
mise-tracked packages or apply mise's release hold. Review the preview before
applying upgrades.

## Customization

- Shared changes belong in tracked files under `zsh/`, `git/`, `vim/`,
  `starship/`, or `config/`.
- Machine-only shell settings belong in `~/.zshenv.local` or `~/.zshrc.local`.
- Git identity and private Git settings belong in `~/.gitconfig.local`.
- GitHub CLI auth state (`config/gh/hosts.yml`), environment files, and local
  overrides are ignored. Never force-add them to Git.

Shared whole-file configs are symlinked, so editing a live linked file edits the
repository immediately. Shell rc files are different: mise owns only marked
source blocks in `~/.zshenv` and `~/.zshrc`; surrounding host content remains
local. Caches and Zsh bytecode are generated and ignored.

## Recovery

```bash
mise bootstrap status --missing
mise bootstrap dotfiles diff
mise run repair
./scripts/generate-caches.sh
```

Do not use force-apply to overwrite an unmanaged host file. `mise run repair`
removes only redundant canonical repo source lines; it reports any other rc
drift without editing it.

## Herdr

Herdr is optional. When enabled, its config is managed at
`~/.config/herdr/config.toml`; the default prefix is `Ctrl-Space`. On macOS,
disable these shortcuts in **System Settings → Keyboard → Keyboard Shortcuts**
so they don't intercept Herdr bindings:

- **Input Sources → Select the previous input source** (`Ctrl-Space`)
- **Mission Control → Mission Control** (`Ctrl-Up`)
- **Mission Control → Application windows** (`Ctrl-Down`)

The tracked config contains the complete binding reference.

AI agents should start with [`AGENTS.md`](AGENTS.md), then read the focused
architecture, troubleshooting, or maintenance document under `docs/agents/`.
