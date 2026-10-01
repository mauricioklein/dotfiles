# Architecture

## Control flow

`bootstrap.sh` performs only the work mise cannot do before its config exists:

1. Install mise with the official installer if it is missing.
2. Resolve the checkout and create `~/.dotfiles` plus
   `~/.config/mise/config.toml` symlinks, then trust the config.
3. Preserve an existing Git identity in `~/.gitconfig.local` when that file is
   absent; prompt only for missing values. Legacy regular Git or hushlogin files
   are moved to a `.dotfiles-backup` path rather than overwritten during the
   symlink handoff.
4. Run `mise bootstrap`.

Mise then applies bootstrap packages, dotfiles, tools, and the `bootstrap` task.
The task runs `scripts/generate-caches.sh`, which creates shell integrations and
Zsh bytecode. The two initial symlinks are the small chicken-and-egg bridge that
lets mise find and manage its own config while Zsh has a stable clone-independent
path.

## Ownership model

- `mise.toml` is the control plane and source of truth for tools, packages,
  dotfiles, and tasks.
- Shared whole-file dotfiles are symlinked into place, including Git config,
  hushlogin, Vim, Git ignore, and XDG config entries. Editing either the repo
  source or its live symlink edits the same file.
- The Zsh site-functions target uses `symlink-each`: the target directory stays
  in place while individual generated completions are linked.
- `~/.zshenv` and `~/.zshrc` are host files. Mise owns only their marked source
  blocks; content outside those blocks remains host-managed.
- `~/.gitconfig.local`, `~/.zshenv.local`, and `~/.zshrc.local` are intentionally
  unmanaged machine-local overrides. Git identity belongs in the first one.
- `zsh/cache/` and `*.zwc` are ignored, machine-specific generated artifacts.

Do not treat “mise applied” as proof that unmarked host rc content is correct.

## Runtime order

Every Zsh process loads `zsh/.zshenv`: locale, XDG paths, PATH, defaults, and
then `.zshenv.local`. Interactive shells load `zsh/.zshrc`, which then loads:

1. `zsh/core/*.zsh` in filename order;
2. `zsh/config/*.zsh` in filename order;
3. mise activation;
4. pre-generated direct integrations for starship, zoxide, FZF, and Worktrunk;
5. `~/.zshrc.local`, followed by the optional repo-local rc override.

The repo Zsh files guard against duplicate loading. Local overrides are loaded
last so machine-specific settings can win.

## Package classes and version policy

- Mise itself is installed by `bootstrap.sh` only when absent.
- Bootstrap system packages are declared under `[bootstrap.packages]`.
- Runtime and CLI tools are declared under `[tools]`; their current inventory is
  always in `mise.toml`, not in this document.
- Git identity, shell-local overrides, credentials, and unrelated host software
  remain local rather than being imported into the repository.

`latest` selectors intentionally roll within policy. Node and Python use major
or minor constraints, while Java has an exact selector. `minimum_release_age =
"2d"` applies to mise-managed release selection. Do not add a lockfile or let
routine update tasks rewrite selectors; changing a selector is an explicit
compatibility decision.

## Paths and invariants

The checkout may live anywhere. Resolve its physical path with `pwd -P`, and use
`~/.dotfiles` for runtime paths. On macOS, Homebrew-backed tools commonly use
`/opt/homebrew/bin`; the shell config also contains the Linuxbrew alternative.

Changes must preserve:

- idempotent bootstrap and repair;
- local identity and override secrecy;
- the marked-block boundary in host rc files;
- generated direct loads after tool updates;
- startup performance as a human-reviewed measurement, not an automated limit.
