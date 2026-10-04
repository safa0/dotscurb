# Roadmap

Next, roughly in order. Each item keeps the rule: dotscurb only fills gaps the other tools leave.

- **Several project folders.** `dotscurb.projects` is already multi-valued in git config
  (`git config --global --add dotscurb.projects ~/work`) and `dotscurb doctor` checks every folder, but chezmoi only
  asks for one. Ask for a list at init; let repos outside any folder be added one by one.
- **Repos with their own `core.hooksPath` (husky, lefthook).** Today dotscurb's hooks don't run there; `doctor` flags
  them. Hand over to the repo's hooks folder instead of `.git/hooks`, then use dotscurb's path everywhere.
- **Secrets** behind one `with-secrets` wrapper (backend: pass, 1Password `op run`, or Infisical), referenced from MCP
  configs by name.
- **Policy for Codex and OpenCode** (Claude and Cursor are done; pi has no permission system).
- **Plugin switch-on in Cursor and Codex**, and session notices outside Claude (only Claude runs `check` at start).
- **Real Linux server run** (herdr, agent logins, `chsh` to zsh).
- Upstream pull requests to dotagents (plugin registration #176, synced skills #193).
