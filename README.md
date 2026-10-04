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
  dotscurb init          first run (via install.sh): wires dotscurb into your own dotfiles repo, asks the questions
  dotscurb setup         what chezmoi runs after each apply: mise install, dotagents install/sync, herdr hooks,
                         dotscurb apply; on the first run it also prints dotscurb doctor
  dotscurb doctor        checklist with the fix for each item: tools, git, agent logins, herdr, items installed
                         outside dotagents, and the repos in your project folders
  dotscurb check [--fix] finds MCP servers and plugins installed directly in an agent (e.g. `claude plugin install`)
                         and moves them into dotagents, removing the native copy; secret values are never copied
  defaults/              shared content: AGENTS.md rules, policy.yaml, mise.toml tool list, a starter agents.toml
```

## Set up a new machine

dotscurb holds only the shared parts. Your own settings live in **your own dotfiles repo** (chezmoi), which fetches
dotscurb next to it. Every user has their own repo; nobody points at someone else's.

Prerequisites: `git`, `curl`, `zsh` or `bash`, GitHub access to this repo (`gh auth login`).

```sh
gh api repos/safa0/dotscurb/contents/install.sh -H "Accept: application/vnd.github.raw" | sh
```
(The repo is private, so plain `curl` from raw.githubusercontent.com returns 404; `gh` sends your login. Once the repo
is public: `curl -fsSL https://raw.githubusercontent.com/safa0/dotscurb/main/install.sh | sh`.)

The installer clones dotscurb to `~/.local/share/dotscurb` and runs `dotscurb init`, which:
1. installs chezmoi if missing;
2. asks for your dotfiles repo: give its URL (or GitHub user), or leave it empty to start a new one;
3. asks a few questions once: name, email, GitHub user and id (for the agent co-author line), the folders that hold
   your repos (comma-separated), and which optional tools mise should install (Node, Claude Code, Codex, Cursor CLI,
   pi, herdr, worktrunk, direnv, tmux, uv, gitleaks; default yes only for tools you don't have). Answers go into
   YOUR repo: `.chezmoidata/dotscurb.toml` and `dot_config/mise/conf.d/dotscurb-extras.toml`;
4. wires dotscurb into your repo: `.chezmoiexternal.toml` entry that fetches dotscurb, a run script
   (`dotscurb setup`), links, and small `modify_` scripts that only add dotscurb's lines to `.gitconfig` and shell
   files. Files your repo already manages are patched in place (plain files) or left to you with a note (templates);
   your `~/.agents/agents.toml` and `policy.yaml` are added if they exist;
5. shows the changes, applies them (`dotscurb setup` → tools, skills/MCP/plugins, policy) and prints the
   `dotscurb doctor` checklist (agent logins etc.);
6. new repo: commits it and offers to create a private GitHub repo `dotfiles` and push. Existing repo: you review and commit.

Start over: `dotscurb uninstall` removes dotscurb's lines, links and files from your home folder and your dotfiles
repo (it keeps your repo, `agents.toml`, policy, skills and logins), then run the installer again.

Another machine: run the same installer and give it your dotfiles repo. Change answers: `dotscurb init --reconfigure`.
Update: `chezmoi update`.

## How a machine uses it

chezmoi does the placing, from your dotfiles repo (`dotscurb init` copies the files from `template/`):

| chezmoi places | from dotscurb |
|---|---|
| `.gitconfig`: `core.hooksPath = ~/.local/share/dotscurb/hooks`, `dotscurb.coauthor` | `hooks/` |
| `~/.agents/AGENTS.md` → link; `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/AGENTS.md` → links to it | `defaults/AGENTS.md` |
| `~/.config/mise/conf.d/dotscurb.toml` → link | `defaults/mise.toml` |
| `~/.local/bin/dotscurb` → link | `bin/dotscurb` |
| `~/.agents/agents.toml`, `~/.agents/policy.yaml` (in your repo) | starter: `defaults/agents.toml`, empty policy |
| `~/.config/mise/conf.d/dotscurb-extras.toml` (your optional tools) | |
| `~/.config/worktrunk/config.toml` (created once) | |
| a run script: `dotscurb setup` | |

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
6. **Project folders, beyond the list.** `dotscurb init` asks for several folders and `doctor` checks every repo in
   them. Still to do: single repos outside any folder, and `check --fix` across all of them.
7. **Repos with their own `core.hooksPath` (husky, lefthook).** dotscurb's hooks don't run there; `doctor` flags them.
   Hand over to the repo's hooks folder instead of `.git/hooks`.
8. **Real Linux server run** (herdr, agent logins, `chsh` to zsh).
