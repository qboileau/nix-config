#!/usr/bin/env bash
# gc-estimate.sh
# Estimate disk space reclaimable by garbage collection, broken down by source:
#   1. Old system generations       (NixOS)
#   2. Old home-manager generations (per-user profile)
#
# Why not just `nix-collect-garbage --dry-run`? On recent Nix it prints only a
# total *count* (no per-path sizes) AND ignores `-d`, so it never reflects the
# space held by old generations — which is usually the bulk of it. Instead we
# compute, per profile, the closure of the deletable generation links minus the
# closure of everything that stays live, and sum the exclusive paths with `du`.
#
# No sudo needed to ESTIMATE: reading generation symlinks and querying the store
# is unprivileged. Deleting old *system* generations later still needs sudo.
#
# Usage:
#   ./scripts/gc-estimate.sh

set -euo pipefail

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

SYSTEM_PROFILE="/nix/var/nix/profiles/system"
HM_PROFILE="${XDG_STATE_HOME:-$HOME/.local/state}/nix/profiles/home-manager"
HM_LIVE_ROOT="${XDG_STATE_HOME:-$HOME/.local/state}/home-manager/gcroots/current-home"

# --- Collect the generation links we would delete (all but the current one) ---
# A profile's current generation is kept by `nix-collect-garbage -d`; everything
# older is fair game.
deletable_links() { # $1 = profile path
	local profile="$1" current link
	[ -e "$profile" ] || return 0
	current="$(readlink -f "$profile")"
	for link in "$profile"-*-link; do
		[ -e "$link" ] || continue
		[ "$(readlink -f "$link")" = "$current" ] && continue
		printf '%s\n' "$link"
	done
}

sys_links="$(deletable_links "$SYSTEM_PROFILE")"
hm_links="$(deletable_links "$HM_PROFILE")"

sys_count="$( [ -n "$sys_links" ] && printf '%s\n' "$sys_links" | wc -l || echo 0 )"
hm_count="$(  [ -n "$hm_links"  ] && printf '%s\n' "$hm_links"  | wc -l || echo 0 )"

if [ "$sys_count" -eq 0 ] && [ "$hm_count" -eq 0 ]; then
	echo -e "${GREEN}No old generations to delete — nothing to estimate.${NC}"
	exit 0
fi

echo -e "${BOLD}Estimating space held by old generations...${NC}"
echo "Walking the live closure — this can take a minute."

# --- Build the "keep" set: closure of every GC root EXCEPT the links above ---
# Any store path still reachable from a surviving root is NOT reclaimable.
declare -A DELETABLE=()
while IFS= read -r l; do
	[ -n "$l" ] || continue
	DELETABLE["$l"]=1
	DELETABLE["$(readlink -f "$l")"]=1
done < <(printf '%s\n%s\n' "$sys_links" "$hm_links")

keep_targets="$(
	nix-store --gc --print-roots 2>/dev/null | while IFS= read -r line; do
		target="$(grep -oE '/nix/store/[^ ]+' <<<"$line" | tail -1)"
		[ -n "$target" ] || continue
		link="${line%% -> *}"
		link="${link%\"}"; link="${link#\"}"
		[ -n "${DELETABLE[$link]:-}" ] && continue
		printf '%s\n' "$target"
	done
)"
# Belt-and-suspenders: always keep the running system + live home-manager.
keep_targets="$(printf '%s\n%s\n%s\n' \
	"$keep_targets" \
	"$(readlink -f /run/current-system 2>/dev/null)" \
	"$(readlink -f "$HM_LIVE_ROOT" 2>/dev/null)")"

keep_closure="$(printf '%s\n' "$keep_targets" | grep '^/nix/store/' | sort -u \
	| xargs -r nix-store -qR 2>/dev/null | sort -u)"

# Human-readable on-disk size of the paths in $1 (newline store-path list) that
# are absent from the kept closure. Prints "0" when nothing is exclusive.
reclaim_size() { # $1 = deletable generation links
	local links="$1" targets dead
	[ -n "$links" ] || { echo 0; return; }
	targets="$(printf '%s\n' "$links" | xargs -r nix-store -qR 2>/dev/null | sort -u)"
	dead="$(comm -23 <(printf '%s\n' "$targets") <(printf '%s\n' "$keep_closure"))"
	[ -n "$dead" ] || { echo 0; return; }
	printf '%s\n' "$dead" | xargs du -sch 2>/dev/null | tail -1 | awk '{print $1}'
}

sys_size="$(reclaim_size "$sys_links")"
hm_size="$(reclaim_size "$hm_links")"

# Paths that are already dead (build leftovers, unreferenced roots) — freed even
# by a plain `nix-collect-garbage`, and disjoint from the live generation paths
# above (a live generation's requisites are all live by definition).
dead_paths="$(nix-store --gc --print-dead 2>/dev/null | grep '^/nix/store/' || true)"
if [ -n "$dead_paths" ]; then
	dead_size="$(printf '%s\n' "$dead_paths" | xargs du -sch 2>/dev/null | tail -1 | awk '{print $1}')"
	dead_count="$(printf '%s\n' "$dead_paths" | wc -l)"
else
	dead_size="0"; dead_count="0"
fi

echo
printf "${BOLD}%-30s %8s  %s${NC}\n" "SOURCE" "PATHS/GENS" "RECLAIMABLE"
printf "%-30s %8s  ${CYAN}%s${NC}\n" "Already-dead paths"            "$dead_count" "$dead_size"
printf "%-30s %8s  ${CYAN}%s${NC}\n" "Old system generations"       "$sys_count"  "$sys_size"
printf "%-30s %8s  ${CYAN}%s${NC}\n" "Old home-manager generations" "$hm_count"   "$hm_size"
echo -e "${YELLOW}(buckets are disjoint but closures overlap the live system, so sizes are exclusive reclaim)${NC}"
echo

# Orphaned home-manager profile: live HM comes from the NixOS module, so the
# per-user profile (and even its "current" generation) is stale.
if [ -e "$HM_PROFILE" ] && [ -e "$HM_LIVE_ROOT" ] \
	&& [ "$(readlink -f "$HM_PROFILE")" != "$(readlink -f "$HM_LIVE_ROOT")" ]; then
	echo -e "${YELLOW}Note:${NC} home-manager runs as a NixOS module; the per-user profile is"
	echo "      orphaned. Its current generation is also stale — remove the whole"
	echo "      profile to reclaim everything:"
	echo "        rm ${HM_PROFILE}*-link ${HM_PROFILE}"
fi

echo "To free system + home-manager garbage: sudo nix-collect-garbage -d"
