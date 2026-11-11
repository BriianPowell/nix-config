# direnv helper: put the Node version a repo pins (.nvmrc or .node-version) on PATH.
#
# Node versions come from nvm.fish, not nix (see home/modules/fish.nix), and nvm.fish does
# not switch on `cd`. This runs inside direnv's bash, so it cannot call `nvm`; it only
# reads the directories nvm.fish already installed. It never installs anything: when the
# version is missing it says how, and the shell still loads.
#
# Usage in a repo's .envrc:   use_nvmrc
# Accepts `21`, `v21`, `21.7`, `v21.7.1`; the highest installed match wins. Aliases
# (`lts/iron`, `node`, `latest`) are not resolved: they print a note and are skipped.
use_nvmrc() {
  local file want root best

  file=$(find_up .nvmrc) || true
  [ -n "$file" ] || file=$(find_up .node-version) || true
  if [ -z "$file" ]; then
    log_status "use_nvmrc: no .nvmrc or .node-version found"
    return 0
  fi
  watch_file "$file"

  want=$(tr -d '[:space:]' <"$file")
  want=${want#v}
  case "$want" in
    "" | [!0-9]*)
      log_status "use_nvmrc: '$want' in ${file#"$PWD"/} is an alias, not a version; skipping (run: nvm use)"
      return 0
      ;;
  esac

  root="${nvm_data:-${XDG_DATA_HOME:-$HOME/.local/share}/nvm}"

  # Exact version first, then the highest installed one with that prefix.
  if [ -x "$root/v$want/bin/node" ]; then
    best="$root/v$want"
  else
    best=$(
      for d in "$root"/v"$want".*; do
        [ -x "$d/bin/node" ] && printf '%s\n' "$d"
      done | sort -V | tail -n 1
    )
  fi

  if [ -z "$best" ]; then
    log_error "use_nvmrc: Node $want is not installed; run: nvm install (in this repo)"
    return 0
  fi

  PATH_add "$best/bin"
  log_status "use_nvmrc: Node ${best##*/v}"
}
