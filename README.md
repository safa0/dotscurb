# dotscurb

Only the glue the other tools don't provide, for a coding-agent setup on macOS and Linux.
Every tool does its own job; dotscurb fills the gaps between them.

```
chezmoi     places files and links (your dotfiles repo uses dotscurb's files, see below)
mise        installs the CLI tools, dotagents included (defaults/mise.toml)
dotagents   skills, MCP servers and plugins for Claude, Cursor, Codex, pi, OpenCode
git         runs the hooks in hooks/
dotscurb    the gaps:
  hooks/                 commit format, attribution, push check, worktree setup, hand-over to each repo's own hooks
  dotscurb apply         one policy → Claude Code and Cursor CLI formats; switches on in Claude the plugins dotagents
                         declares (dotagents only generates the marketplace, issue #176)
  dotscurb check [--fix] finds MCP servers and plugins installed directly in an agent (e.g. `claude plugin install`)
                         and moves them into dotagents, removing the native copy; secret values are never copied
  defaults/              shared content: AGENTS.md rules, policy.yaml, mise.toml tool list, a starter agents.toml
```

## Set up a new machine

Prerequisites: `git`, `zsh` or `bash`, `curl`, Node 20+ (for dotagents), GitHub access to this repo (`gh auth login`).

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
~/.local/bin/chezmoi init --apply https://github.com/safa0/dotscurb.git
exec zsh
```

chezmoi asks four questions once (name, email, GitHub username and numeric id for the agent co-author line), then uses
`template/` in this repo. It only adds to your existing `~/.gitconfig` and shell files: the hooks path, the co-author
line, a missing name/email, and one PATH line. Update later with `chezmoi update`.

Already using chezmoi for your own dotfiles? Copy `template/` into your repo and point it at a dotscurb checkout
(e.g. with `.chezmoiexternal.toml`) instead.

## How a machine uses it

chezmoi does the placing (`template/`, or the same files in your own dotfiles repo):

| chezmoi places | from dotscurb |
|---|---|
| `.gitconfig`: `core.hooksPath = ~/.local/share/dotscurb/hooks`, `dotscurb.coauthor` | `hooks/` |
| `~/.agents/AGENTS.md` → link; `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/AGENTS.md` → links to it | `defaults/AGENTS.md` |
| `~/.config/mise/conf.d/dotscurb.toml` → link | `defaults/mise.toml` |
| `~/.local/bin/dotscurb` → link | `bin/dotscurb` |
| `~/.agents/agents.toml`, `~/.agents/policy.yaml` (created once, then yours) | `defaults/agents.toml`, empty policy |
| a run script: `mise install`, `dotagents install`, `dotscurb apply` | |

Prerequisites: `git`, `curl`, Node 20+ (for dotagents), GitHub access to this repo.

## Change things

| To change | Edit | Then |
|---|---|---|
| what agents may not do | `~/.agents/policy.yaml` (adds to `defaults/policy.yaml`) | `dotscurb apply` |
| a skill, MCP server or plugin for every project | `dotagents add …` / `dotagents mcp add …` | `dotscurb apply` (plugins) |
| the same for one project | `dotagents --project …` in the repo; commit `agents.toml` | |
| something installed directly in an agent | | `dotscurb check --fix` |
| shared defaults for everyone | this repo | commit; everyone's `chezmoi apply` picks it up |

## Scope

v1: the hooks, policy rendering for Claude and Cursor, Claude plugin switch-on, `check` / `check --fix` for MCP
servers (all five agents) and Claude plugins: user-level ones move to dotagents, project-level ones are recorded in the
repo's `agents.toml` and switched on in Claude per project. Tested on macOS and a fresh Ubuntu container.

Everything else is on the roadmap below.

## Roadmap

Same rule as v1: only add what the other tools don't already do, and drop pieces once a tool covers them.

1. **Secrets store.** MCP servers get keys only as `${VAR}` references today; servers whose native config holds a
   literal key are skipped by `check --fix`. Pick a store that works over SSH and on Linux (Infisical, 1Password CLI
   or `pass`) and pass keys only to the MCP process, never into the shell or `agents.toml`.
2. **Plugin switch-on in Cursor and Codex.** dotagents writes their plugin marketplaces (`.cursor-plugin/`,
   `.agents/plugins/marketplace.json`) but doesn't register or enable them (dotagents issues #176, #178).
   `dotscurb apply` does this for Claude only.
3. **Policy for Codex and OpenCode.** Render `policy.yaml` into Codex (approval and sandbox settings) and OpenCode
   (`permission` in `opencode.json`). pi has no permission system.
4. **Session notices outside Claude.** Run `dotscurb check --session` at session start in Cursor, Codex and pi, as
   Claude does today.
5. **Upstream to dotagents.** Send pull requests for the gaps dotscurb fills (importing native installs, plugin
   activation, distinct project marketplace names), then remove those parts from dotscurb when they ship.
