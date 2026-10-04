# dotscurb: git skips a repo's own .git/hooks because core.hooksPath points here.
# dotscurb_chain <hook-name> [args...] runs the repo's own hook of the same name, if any, with the same stdin.
dotscurb_chain() {
  _name=$1; shift
  _dir=$(git rev-parse --git-common-dir 2>/dev/null) || return 0
  _hook="$_dir/hooks/$_name"
  [ -x "$_hook" ] || return 0
  "$_hook" "$@"
}
