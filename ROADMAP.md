# Roadmap

Next, roughly in order. Each item keeps the rule: dotscurb only fills gaps the other tools leave.

- **Project folders, beyond the list.** `dotscurb init` asks for a comma-separated list and `doctor` checks every
  folder. Still to do: single repos outside any folder (`dotscurb.repo` entries), and using the list for more than
  doctor (e.g. `check --fix` across all repos).
- **Repos with their own `core.hooksPath` (husky, lefthook).** Today dotscurb's hooks don't run there; `doctor` flags
  them. Hand over to the repo's hooks folder instead of `.git/hooks`, then use dotscurb's path everywhere.
- **Secrets** behind one `with-secrets` wrapper (backend: pass, 1Password `op run`, or Infisical), referenced from MCP
  configs by name.
- **Policy for Codex and OpenCode** (Claude and Cursor are done; pi has no permission system).
- **Plugin switch-on in Cursor and Codex**, and session notices outside Claude (only Claude runs `check` at start).
- **Real Linux server run** (herdr, agent logins, `chsh` to zsh).
- Upstream pull requests to dotagents (plugin registration #176, synced skills #193).
