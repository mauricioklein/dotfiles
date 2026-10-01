# Agent guide

This repository is a live, mise-managed dotfiles system. `~/.dotfiles` is the
canonical runtime path and normally points to this checkout.

## Start here

```bash
pwd -P
git status --short
mise run check
```

`mise.toml`, `bootstrap.sh`, and the scripts under `scripts/` are authoritative.
Use the focused document that matches the task:

| Task | Read |
| --- | --- |
| Architecture or setup | [`docs/agents/architecture.md`](docs/agents/architecture.md) |
| Incident or repair | [`docs/agents/troubleshooting.md`](docs/agents/troubleshooting.md) |
| Updates, tools, or configs | [`docs/agents/maintenance.md`](docs/agents/maintenance.md) |

## Safety and ownership

- Edit tracked linked files in this repository; linked live files update it immediately.
- `~/.zshenv` and `~/.zshrc` are host files with mise-owned marked blocks. Repair removes only redundant canonical repo source lines; never rewrite other surrounding content automatically.
- `~/.zshenv.local`, `~/.zshrc.local`, and `~/.gitconfig.local` are host-local and private. Never print, copy, commit, or include their contents in a report.
- Generated caches and Zsh bytecode are ignored. Regenerate them; do not commit them.
- Run update previews first and get approval before applying updates, installing packages, pruning versions, changing exact/major selectors, or changing host files. Do not use force-apply for routine repair.
- Do not pull source, import packages, self-update mise, or remove files as part of routine updates without explicit approval.
- Never crawl `$HOME` or inspect unrelated home files. Use bounded status and dry-run commands.

Keep changes small and idempotent. After editing, run `mise run check` and review
`git diff` without exposing credentials or host-local configuration.
