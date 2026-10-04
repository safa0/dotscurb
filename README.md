# dotscurb

The glue between the tools that set up a coding-agent machine. One repo, one command, macOS and Linux, no sudo.
It sets up the same rules, tools, git hooks and agent configuration for Claude Code, Cursor CLI, Codex, pi and
OpenCode, and leaves the tools themselves untouched.

```
            your dotfiles (chezmoi, optional): identity, shell look, personal settings
                                     │ installs dotscurb, runs `dotscurb install`
                                     ▼
  dotscurb:  git hooks · agent policy · shared AGENTS.md · links · tool list · `dotscurb check` · `dotscurb da`
                                     │
          ┌──────────────┬───────────┴─────────┬──────────────┐
      dotagents         mise                worktrunk        herdr
 (skills, MCP, plugins) (CLI tools)         (worktrees)      (panes)
```

## Install

Needs `git`, `curl` and, for dotagents, Node (`npx`).

```sh
git clone https://github.com/safa0/dotscurb.git ~/.local/share/dotscurb
~/.local/share/dotscurb/bin/dotscurb install
```

`install` is safe to re-run. It never overwrites a real file it doesn't own; it only creates links and sets the keys
listed below.

## What it does

| Piece | Where | What it does |
|---|---|---|
| CLI tools | `~/.config/mise/conf.d/dotscurb.toml` | pinned rg, fd, ast-grep, jq, yq, gh via mise (installs mise if missing) |
| Git hooks | `core.hooksPath` → `hooks/` | Conventional Commits subjects; strips agent attribution and adds your `Co-authored-by: <you>'s Agent` on agent commits; blocks pushes carrying attribution; sets up new worktrees (`.env*`, `.worktreeinclude`, submodules); then runs the repo's own `.git/hooks/<name>` |
| Shared rules | `~/.agents/AGENTS.md` | generated from `defaults/AGENTS.md` + your `~/.agents/AGENTS.personal.md`; linked as `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/AGENTS.md` (Cursor and pi) |
| Skills | `~/.agents/skills` | one folder for every agent; `~/.claude/skills` links to it |
| Policy | `~/.agents/policy.yaml` + `defaults/policy.yaml` | deny rules and attribution off, rendered into Claude (`settings.json`) and Cursor (`cli-config.json`); only those keys are touched |
| Skills + MCP | `~/.agents/agents.toml` | dotagents config; `dotscurb da …` runs dotagents at the pinned version |
| Drift check | `dotscurb check` | lists MCP servers and plugins installed outside dotagents; Claude runs it at session start |

## Change things

| To change | Edit | Then |
|---|---|---|
| what agents may not do | `~/.agents/policy.yaml` (adds to the defaults) | `dotscurb apply` |
| your own agent rules | `~/.agents/AGENTS.personal.md` | `dotscurb apply` |
| a skill or MCP server for every project | `dotscurb da add …` / `dotscurb da mcp add …` | done |
| a skill or MCP server for one project | `dotscurb da --project add …` in the repo, commit `agents.toml` | done |
| shared defaults for everyone | this repo (`defaults/`, `hooks/`) | commit, everyone runs `dotscurb install` |

The co-author line comes from `git config --global dotscurb.coauthor`, set from your GitHub login on install.

## Scope

v1 is done when all of these hold:

1. This repo holds every glue piece: hooks with hand-over to repo hooks, policy rendering for Claude and Cursor,
   shared AGENTS.md and links, skills link, mise tool list, `dotscurb da`, `dotscurb check`, Claude session notice.
2. `dotscurb install` sets up a machine, tested on a fresh Ubuntu container (non-root) and on macOS with no change in
   behaviour.
3. chezmoi keeps only personal things and installs dotscurb.
4. Tests pass: commit format and trailer, push block, worktree setup, repo hook hand-over, deny rules in Claude and
   Cursor with no drift, `dotscurb check` flags a native MCP install.
5. This README covers install, what it does, and how to change it.

Not in v1: a secrets store (MCP keys stay `${VAR}` references), plugins through dotagents, Codex and OpenCode policy,
Cursor/Codex/pi session notices, a shared skills library repo, upstream pull requests to dotagents.
