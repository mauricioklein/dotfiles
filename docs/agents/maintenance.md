# Maintenance

## Preview, apply, verify

For normal maintenance:

```bash
mise run update:preview
# review the output and approve the intended changes
mise run update
mise run check
git diff -- mise.toml scripts zsh git README.md AGENTS.md docs/agents
```

`mise run check` is read-only. `mise run repair` applies the declared setup,
removes redundant canonical repo source lines, regenerates ignored artifacts,
and checks the result. It does not rewrite other host rc content. Use `mise bootstrap
--dry-run` or the narrower dotfiles dry-run when investigating before repair.
Do not use `--force-dotfiles` for routine work: it can overwrite unmanaged
files. Do not combine routine updates with `git pull`, package import, pruning,
or mise self-update.

## Version policy

The two-day `minimum_release_age` in `mise.toml` is the release hold for
mise-managed updates. `mise run update:preview` shows:

- `mise upgrade --dry-run` for updates within current selectors;
- `mise outdated --bump` for candidates outside those selectors;
- bootstrap package upgrades;
- prunable installed versions; and
- Homebrew formulae that could be imported, without writing the config.

`mise run update` upgrades only within declared selectors, upgrades declared
bootstrap packages, regenerates integrations, and runs the check. It does not
rewrite `mise.toml`. Review any explicit change to a Node/Python constraint or
exact Java selector as a compatibility decision before applying it. Updating
mise itself is a separate, approved maintenance step.

## Tools and configuration

To add a tool, add its selector under `[tools]`, run the preview, and then use
`mise run repair` or the approved update flow. Add a `[dotfiles]` entry only
when the configuration is shared, safe to keep in Git, and demonstrably
consumed by the tool. Keep credentials, tokens, and host-specific settings in
unmanaged local files.

When a tool has shell integration, update `scripts/generate-caches.sh` and its
Zsh plugin together. Run the generator after changing the tool or integration;
its output and Zsh bytecode remain ignored. A tool with no tracked config needs
no new documentation inventory: `mise.toml` is the inventory.

To remove a tool, remove its selector and any tracked config or alias that
requires it, preview the result, then prune only after approval. Removing a
config should include a deliberate check for the tool's live
`~/.config/<tool>` target; never copy arbitrary home files into the repo.

## Safe discovery and cadence

- `git status --short --untracked-files=all` finds new files created inside
  linked repository directories.
- `mise bootstrap status --missing` and dotfile diff show managed drift.
- `mise bootstrap packages import --manager brew --dry-run --path mise.toml`
  previews requested Homebrew formulae without importing them.
- For a new tool, deliberately check its documented `~/.config/<tool>` path;
  never scan all of `$HOME`.
- Do not auto-import packages, copy unknown files, add a watcher, or create a
  scheduled updater.

Run the preview monthly or when setup changes. A light on-demand cadence is
preferred to cron or scheduled dependency pull requests.
