#!/usr/bin/env bash
# list-generations.sh
# List NixOS system generations with their closure size on disk.
#
# Combines `nixos-rebuild list-generations` (generation metadata: number,
# date, NixOS version, kernel, current marker) with `nix path-info -S`
# (total closure size of each generation) into a single clean table.
#
# Note: closure sizes overlap heavily between generations because they share
# store paths. The sum is NOT the disk space you'd reclaim by deleting them;
# use `nix-collect-garbage --dry-run` for that.
#
# Usage:
#   ./scripts/list-generations.sh

set -euo pipefail

SYSTEM_PROFILE="/nix/var/nix/profiles"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Human-readable size for a store path's whole closure (e.g. "1.2G").
closure_size() {
	nix path-info -Sh "$1" 2>/dev/null | awk '{print $(NF-1) $NF}'
}

printf "${BOLD}%-5s %-19s %-14s %-9s %s${NC}\n" "GEN" "DATE" "SIZE" "CURRENT" "DESCRIPTION"

# `nixos-rebuild list-generations --json` gives structured metadata.
nixos-rebuild list-generations --json \
	| jq -r '.[] | [.generation, .date, .nixosVersion, .kernelVersion, (.current|tostring)] | @tsv' \
	| while IFS=$'\t' read -r gen date version kernel current; do
		link="$SYSTEM_PROFILE/system-${gen}-link"
		size="$(closure_size "$link")"
		: "${size:=?}"

		marker=""
		if [ "$current" = "true" ]; then
			marker="${GREEN}*${NC}"
		fi

		# Trim the date to just YYYY-MM-DD HH:MM.
		short_date="${date:0:16}"

		printf "%-5s %-19s ${CYAN}%-14s${NC} %-9b %s\n" \
			"$gen" "$short_date" "$size" "$marker" "NixOS $version (kernel $kernel)"
	done

echo
echo "Note: closure sizes overlap (shared store paths); the sum is not reclaimable space."
echo "Run 'nix-collect-garbage --dry-run' to see what deleting old generations would free."
