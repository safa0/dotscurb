# Shared rules for all coding agents

Shared by dotscurb (`~/.local/share/dotscurb/defaults/AGENTS.md`); `~/.agents/AGENTS.md` links here.
Claude and Codex read it through `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`; Cursor and pi find `~/AGENTS.md` from any project under your home folder.

## Shell tools
Prefer your built-in search and edit tools. In the shell use `rg` (not `grep -r`), `fd` (not `find`),
`ast-grep` for structural search and rewrites (not regex/`sed` on code; call it `ast-grep`, not `sg`),
`jq` for JSON, `yq` for YAML/TOML. `rg`/`fd` skip gitignored files; add `-uu` / `-HI` when needed.

## Worktrees
- Do each task in its own git worktree, not in the main checkout.
- Create it with `wt switch --create <branch>`. That puts it next to the repo: `<repo>-worktrees/<branch>`.
  Without `wt`: `git worktree add ../<repo>-worktrees/<branch> -b <branch>`.
- Do not use agent-specific worktree flags (`codex --worktree`, `cursor-agent -w`, `claude -w`); they use other paths.
- Setup is automatic. A global git `post-checkout` hook copies gitignored `.env*` files and the paths listed in the
  repo's `.worktreeinclude` into every new worktree, and initialises submodules. Do not copy secrets by hand.
- Remove a worktree with `wt remove <branch>` or `git worktree remove <path>`; never delete the folder by hand,
  and never remove a worktree you did not create.

## Commits
- Subject format: `<type>(<scope>): <summary>` (Conventional Commits; types: feat fix docs style refactor perf test build ci chore revert).
  A global hook rejects other subjects.
- Do not add `Co-Authored-By`, `Generated with`, or similar attribution lines. A global hook strips them and adds the
  correct trailer for agent commits.

## Skills, MCP servers and plugins
- Install and switch them on only through dotagents, the `dotagents` command:
  - this project only: `dotagents --project add <source> [skill]`, `dotagents --project mcp add <name> --url <url>`
    (or `--command "<cmd>"`), then commit the repo's `agents.toml`;
  - every project: the same commands without `--project`.
- Never use `claude mcp add`, `claude plugin install`, `npx skills add` or `codex mcp add`, and never edit an agent's
  MCP or plugin files by hand.
- Never put secret values in `agents.toml`; pass names (`--env NAME`, `${NAME}` in headers).
- If a session starts with a "dotscurb" notice about things installed outside dotagents, tell the user and offer to
  run `dotscurb check --fix`, which moves them into dotagents.
