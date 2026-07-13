#!/usr/bin/env bash
# gc-estimate.sh
# Estimate how much disk space `nix-collect-garbage` would reclaim.
#
# `nix-collect-garbage --dry-run` only reports the *count* of dead store
# paths, never their size. This script captures those paths and sums their
# actual on-disk bytes with `du` (not `nix path-info -S`, whose closure sizes
# overlap and would over-count).
#
# By default it estimates the current user's garbage only. Old *system*
# generations are pinned by the root profile; pass --system (or run as root)
# to include them via sudo.
#
# Usage:
#   ./scripts/gc-estimate.sh            # user garbage only
#   ./scripts/gc-estimate.sh --system   # include old system generations (uses sudo)

set -euo pipefail

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

SUDO=""
SCOPE="user"
if [ "${1:-}" = "--system" ]; then
	SUDO="sudo"
	SCOPE="user + system"
fi

echo -e "${BOLD}Estimating reclaimable space (${SCOPE} scope)...${NC}"
echo "Determining dead store paths (this can take a moment)..."

# Collect the dead paths once, then derive count + size from the same list.
paths="$($SUDO nix-collect-garbage --dry-run 2>/dev/null | grep -oE '/nix/store/[^ ]+' || true)"

if [ -z "$paths" ]; then
	echo -e "${GREEN}Nothing to reclaim — the store is already clean.${NC}"
	exit 0
fi

count="$(printf '%s\n' "$paths" | wc -l)"
total="$(printf '%s\n' "$paths" | xargs du -sch 2>/dev/null | tail -1 | awk '{print $1}')"

echo
echo -e "Dead store paths : ${CYAN}${count}${NC}"
echo -e "Reclaimable      : ${GREEN}${BOLD}${total}${NC}"
echo
if [ "$SCOPE" = "user" ]; then
	echo -e "${YELLOW}Note:${NC} user scope only. Re-run with --system to include old system generations."
fi
echo "To actually free it: sudo nix-collect-garbage -d"
