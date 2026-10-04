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

## How a machine uses it

Your chezmoi repo does the placing (a template repo for others does the same):

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

Not in v1: secrets store, Codex and OpenCode policy, plugin switch-on in Cursor and Codex,
session notices outside Claude, upstream pull requests to dotagents.
