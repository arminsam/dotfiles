#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
IDENTITY="$DIR/identity.nix"

# First run on a new Mac: ask once for host/user, then write identity.nix.
# identity.nix is gitignored so each machine keeps its own values.
if [[ ! -f "$IDENTITY" ]]; then
  detected_host="$(scutil --get LocalHostName 2>/dev/null || hostname -s)"
  detected_user="$(id -un)"
  default_host="mac"

  echo "No identity.nix yet — set host and user for this Mac (saved locally, not committed)."
  echo "  LocalHostName: ${detected_host}"
  echo "  login user:    ${detected_user}"
  echo

  if [[ -t 0 ]]; then
    read -r -p "hostName (flake attr, e.g. mac) [${default_host}]: " host_name
    host_name="${host_name:-$default_host}"
    read -r -p "userName [${detected_user}]: " user_name
    user_name="${user_name:-$detected_user}"
  else
    # Non-interactive (CI / piped): use defaults.
    host_name="$default_host"
    user_name="$detected_user"
    echo "Non-interactive: using hostName=${host_name} userName=${user_name}"
  fi

  cat > "$IDENTITY" <<NIX
{
  hostName = "${host_name}";
  userName = "${user_name}";
}
NIX

  echo
  echo "Wrote ${IDENTITY}"
  echo "  darwin-rebuild will use: ~/.dotfiles#${host_name}"
  echo "Re-run ./rebuild.sh anytime; it will not ask again unless you delete identity.nix."
fi

host_name="$(sed -n 's/^[[:space:]]*hostName[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' "$IDENTITY" | head -1)"
if [[ -z "$host_name" ]]; then
  echo "error: could not parse hostName from $IDENTITY" >&2
  exit 1
fi

ln -sfn "$DIR" ~/.dotfiles
exec sudo darwin-rebuild switch --flake ~/.dotfiles"#${host_name}"
