#!/usr/bin/env bash
# test-sddm-theme.sh
# Preview the SDDM login theme this flake configures, in a normal window,
# without rebooting or restarting the display manager.
#
# Everything is resolved from the flake — nothing is hardcoded:
#   - the theme name comes from services.displayManager.sddm.theme
#   - the theme directory + greeter Qt/QML modules come from sddm.extraPackages
#   - the greeter binary comes from sddm.package (the wrapped sddm-greeter-qt6)
# so what you see matches what `nixos-rebuild switch` would deploy.
#
# Session Qt env is stripped before launching: a Hyprland/qt6ct session exports
# QT_QUICK_CONTROLS_STYLE (e.g. "org.hyprland.style"), which the greeter would
# inherit — `import QtQuick.Controls` then fails to load that style and the theme
# silently falls back to the embedded one. The real SDDM greeter runs in a clean
# systemd env without these, so this only matters when testing from a desktop
# session. QML_DISABLE_DISK_CACHE=1 also avoids a stale compiled-QML cache.
#
# Usage:
#   ./scripts/test-sddm-theme.sh            # host = current hostname
#   ./scripts/test-sddm-theme.sh desktop    # explicit flake host
#
# Notes:
#   - pipewire "Couldn't load pipewire-0.3" warnings are harmless for static
#     (png) backgrounds; they only matter for the .mp4 video variants.
#   - Deprecation / "angle-down.png" warnings come from sddm's own test harness.

set -euo pipefail

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m'

info() { printf "${CYAN}==>${NC} %s\n" "$*"; }
warn() { printf "${YELLOW}warning:${NC} %s\n" "$*" >&2; }
die()  { printf "${YELLOW}error:${NC} %s\n" "$*" >&2; exit 1; }

FLAKE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOST="${1:-$(hostname)}"
CFG=".#nixosConfigurations.${HOST}.config.services.displayManager.sddm"

command -v nix >/dev/null || die "nix not found in PATH"
command -v jq  >/dev/null || die "jq not found in PATH"

cd "$FLAKE"

# --- Resolve the theme name from config ------------------------------------
info "Resolving theme for host '${HOST}' from ${FLAKE}/flake.nix"
THEME_NAME="$(nix eval --raw "${CFG}.theme" 2>/dev/null)" \
  || die "could not read sddm.theme for host '${HOST}' (is it a valid flake host?)"

# --- Realise extraPackages and locate the theme dir + QML module dirs ------
# extraPackages is a *list* of derivations, which `nix build` can't take
# directly. Eval each element's .drvPath (NOT .outPath — an out-path is just a
# computed hash, so `nix build <outpath>` fails with "no substituter can build
# it" whenever the config changes), then realise the derivations. nix-store
# --realise builds from the .drv and prints the resulting out-paths.
mapfile -t DRVS < <(
  nix eval --json "${CFG}.extraPackages" \
    --apply 'ps: map (p: p.drvPath) ps' 2>/dev/null | jq -r '.[]'
)
[ "${#DRVS[@]}" -gt 0 ] || die "sddm.extraPackages is empty for host '${HOST}'"

info "Building greeter + theme packages (may take a moment on first run)..."
mapfile -t EXTRA < <(nix-store --realise "${DRVS[@]}")

THEME_DIR=""
QML_DIRS=()
for p in "${EXTRA[@]}"; do
  cand="$p/share/sddm/themes/${THEME_NAME}"
  [ -d "$cand" ] && THEME_DIR="$cand"
  [ -d "$p/lib/qt-6/qml" ] && QML_DIRS+=("$p/lib/qt-6/qml")
done
[ -n "$THEME_DIR" ] \
  || die "theme '${THEME_NAME}' not found in sddm.extraPackages — is the theme package listed there?"

# --- Resolve the wrapped greeter binary from sddm.package ------------------
GREETER=""
while read -r out; do
  if [ -x "$out/bin/sddm-greeter-qt6" ]; then GREETER="$out/bin/sddm-greeter-qt6"; break; fi
done < <(nix build --no-link --print-out-paths "${CFG}.package")
[ -n "$GREETER" ] || die "sddm-greeter-qt6 not found in sddm.package"

# --- Launch ----------------------------------------------------------------
# The wrapped greeter sets base QML paths (qtdeclarative/qtbase); the daemon
# normally injects the extraPackages QML dirs at runtime, so we do it here.
QML_EXTRA="$(IFS=:; echo "${QML_DIRS[*]}")"

printf "${BOLD}%s${NC} %s\n" "host:  " "$HOST"
printf "${BOLD}%s${NC} %s\n" "theme: " "$THEME_NAME"
printf "${BOLD}%s${NC} ${GREEN}%s${NC}\n" "path:  " "$THEME_DIR"
printf "${BOLD}%s${NC} %s\n" "greeter:" "$GREETER"
echo
info "Launching greeter in test mode (close the window to exit)..."

# Strip session Qt styling that the greeter must not inherit (QT_QUICK_CONTROLS_STYLE
# would otherwise point at the Hyprland style module the greeter can't load), then
# run with the resolved QML paths and disk cache disabled.
exec env \
  -u QT_QUICK_CONTROLS_STYLE \
  -u QT_STYLE_OVERRIDE \
  QML2_IMPORT_PATH="$QML_EXTRA" \
  QML_IMPORT_PATH="$QML_EXTRA" \
  QML_DISABLE_DISK_CACHE=1 \
  "$GREETER" --test-mode --theme "$THEME_DIR"
