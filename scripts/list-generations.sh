#!/usr/bin/env bash
# list-generations.sh
# List NixOS system AND home-manager generations with their closure size on disk.
#
# Combines `nixos-rebuild list-generations` (generation metadata: number,
# date, NixOS version, kernel, current marker) with `nix path-info -S`
# (total closure size of each generation) into a single clean table, then does
# the same for the per-user home-manager profile.
#
# Note: closure sizes overlap heavily between generations because they share
# store paths. The sum is NOT the disk space you'd reclaim by deleting them;
# run `./scripts/gc-estimate.sh` for that.
#
# Usage:
#   ./scripts/list-generations.sh

set -euo pipefail

SYSTEM_PROFILE="/nix/var/nix/profiles"
HM_PROFILE="${XDG_STATE_HOME:-$HOME/.local/state}/nix/profiles/home-manager"
HM_LIVE_ROOT="${XDG_STATE_HOME:-$HOME/.local/state}/home-manager/gcroots/current-home"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

# Human-readable size for a store path's whole closure (e.g. "1.2G").
closure_size() {
	nix path-info -Sh "$1" 2>/dev/null | awk '{print $(NF-1) $NF}'
}

echo -e "${BOLD}System generations${NC}"
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

# --- Home-manager per-user profile generations ---------------------------------
if [ -e "$HM_PROFILE" ]; then
	echo
	echo -e "${BOLD}Home-manager generations${NC} (per-user profile)"
	printf "${BOLD}%-5s %-19s %-14s %-9s %s${NC}\n" "GEN" "DATE" "SIZE" "CURRENT" "STORE PATH"

	hm_current="$(readlink -f "$HM_PROFILE")"

	# `nix-env --list-generations` output: "  <gen>   <date> <time>   (current)".
	nix-env --list-generations --profile "$HM_PROFILE" 2>/dev/null \
		| while read -r gen date time _rest; do
			link="${HM_PROFILE}-${gen}-link"
			size="$(closure_size "$link")"
			: "${size:=?}"

			marker=""
			[ "$(readlink -f "$link")" = "$hm_current" ] && marker="${GREEN}*${NC}"

			store="$(basename "$(readlink -f "$link")")"
			printf "%-5s %-19s ${CYAN}%-14s${NC} %-9b %s\n" \
				"$gen" "$date $time" "$size" "$marker" "$store"
		done

	# When home-manager is a NixOS module, the live config lives in the system
	# closure, not this profile — so every generation here is orphaned.
	if [ -e "$HM_LIVE_ROOT" ] && [ "$hm_current" != "$(readlink -f "$HM_LIVE_ROOT")" ]; then
		echo
		echo -e "${YELLOW}Note:${NC} home-manager runs as a NixOS module; this per-user profile is"
		echo "      orphaned (live config: $(basename "$(readlink -f "$HM_LIVE_ROOT")"))."
		echo "      Every generation above is stale and safe to delete."
	fi
fi

echo
echo "Note: closure sizes overlap (shared store paths); the sum is not reclaimable space."
echo "Run './scripts/gc-estimate.sh' to see what deleting old generations would free."
