# Troubleshooting

Use this ladder. Preserve evidence before repairing anything.

1. Run `git status --short` and avoid force, prune, delete, or overwrite steps.
2. Resolve paths and commands with `pwd -P`, `readlink`, `type -a`, and `mise which`.
3. Run `mise run check`.
4. Inspect `mise bootstrap status --missing`,
   `mise bootstrap dotfiles status --missing`, and
   `mise bootstrap dotfiles diff`.
5. Classify the problem as a bootstrap link, deployed config, shell source
   order, generated cache, completion cache, mise activation/PATH, or local
   override issue.
6. Apply the smallest repair, then rerun syntax and functional smoke checks.
7. For performance issues, take five startup samples after the repair.

`mise bootstrap status` validates managed entries and marked blocks only. It
does not validate extra source lines or other content outside the mise markers
in a host rc file.

## Symptom guide

| Symptom | Diagnose first | Smallest repair and mutation |
| --- | --- | --- |
| A declared command is missing | `type -a <command>`; `mise bootstrap status --missing` | `mise run repair`; changes tool/install state, not repo source |
| Prompt, `z`, FZF history, or `wt` is broken | Check the relevant file under `zsh/cache/` and `command -v starship zoxide fzf wt` | `mise run repair` or `./scripts/generate-caches.sh`; changes ignored generated files |
| Completion is stale or slow | Check `zsh/cache/.zcompdump` age and `mise which zsh` | Remove only `~/.dotfiles/zsh/cache/.zcompdump*`, then start Zsh; changes generated cache |
| Git settings are wrong | Confirm `~/.gitconfig` resolves to the repo and inspect `git config --global --includes --show-origin` locally without copying identity values into a report | Restore the managed link with `mise run repair`; identity repair belongs in private `~/.gitconfig.local` |
| Shell setup runs twice | `mise run check`; it reports duplicate line numbers in `~/.zshenv` or `~/.zshrc` | `mise run repair` removes only redundant canonical repo source lines; other host rc edits remain manual and reviewed |
| Startup is slow | `/usr/bin/time -p zsh -i -c exit` five times; then use a bounded `zsh -x -i -c exit` trace | Regenerate caches or inspect local overrides; generated files or host-local files may change |
| A moved clone breaks paths | `pwd -P`, `readlink ~/.dotfiles`, and `readlink ~/.config/mise/config.toml` | Rerun `./bootstrap.sh`; changes the two bootstrap links and any approved managed state |
| mise activation or PATH is wrong | `type -a mise`; `mise which <tool>`; inspect PATH ordering | Fix the shell/PATH source or local override, then run `mise run check`; do not blindly change harness paths |

Do not print `~/.zshenv.local`, `~/.zshrc.local`, `~/.gitconfig.local`, auth
files, or unrelated home-file contents while diagnosing.
