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
  dotscurb setup         what chezmoi runs after each apply: mise install, dotagents install/sync, herdr hooks,
                         dotscurb apply; on the first run it also prints dotscurb doctor
  dotscurb doctor        checklist with the fix for each item: tools, git, agent logins, herdr, items installed
                         outside dotagents, and the repos in your project folders
  dotscurb check [--fix] finds MCP servers and plugins installed directly in an agent (e.g. `claude plugin install`)
                         and moves them into dotagents, removing the native copy; secret values are never copied
  defaults/              shared content: AGENTS.md rules, policy.yaml, mise.toml tool list, a starter agents.toml
```

## Set up a new machine

Prerequisites: `git`, `zsh` or `bash`, `curl`, GitHub access to this repo (`gh auth login`). Node 20+ is needed for
dotagents; answer yes to Node when asked and mise installs it.

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
~/.local/bin/chezmoi init --apply https://github.com/safa0/dotscurb.git
exec zsh
```

chezmoi asks once:
- name, email, GitHub username and numeric id (the agent co-author line);
- the folder that holds your git repos (`dotscurb.projects` in `~/.gitconfig`; `dotscurb doctor` checks the repos in it);
- which optional tools mise should install: Node, Claude Code, Codex, Cursor CLI, pi, herdr, worktrunk, direnv.
  The default is yes only for tools not already on the machine. Your answers go to `~/.config/mise/conf.d/dotscurb-extras.toml`.

It only adds to your existing files: in `~/.gitconfig` the hooks path, co-author line, project folder and a missing
name/email; one PATH line in the shell profiles; three guarded lines in `~/.zshrc`/`~/.bashrc` (direnv hook, `wt`
shell integration, Cursor CLI file credentials). Then `dotscurb setup` runs and prints the doctor checklist: agent
logins, herdr hooks, anything to move into dotagents. Do what it lists, then `dotscurb doctor` again.
Change answers later with `chezmoi init --prompt`; update with `chezmoi update`.

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
| `~/.config/mise/conf.d/dotscurb-extras.toml` (your optional tools) | |
| `~/.config/worktrunk/config.toml` (created once) | |
| a run script: `dotscurb setup` | |

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

See ROADMAP.md for what's next. Not in v1: secrets store, Codex and OpenCode policy, plugin switch-on in Cursor and Codex,
session notices outside Claude, upstream pull requests to dotagents.
