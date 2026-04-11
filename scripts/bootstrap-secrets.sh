#!/usr/bin/env bash
# bootstrap-secrets.sh
# Bootstrap age master key from Bitwarden on a fresh NixOS install.
# Uses nix shell to provide bitwarden-cli automatically — no manual install needed.
#
# The age master private key is stored as a Bitwarden Secure Note named "nixos-age-key"
#
# Usage:
#   ./bootstrap-secrets.sh                    # Interactive Bitwarden login
#   BW_SESSION=xxx ./bootstrap-secrets.sh     # Use existing session

set -euo pipefail

AGE_KEY_PATH="/var/lib/age/key.txt"
BW_ITEM_NAME="nixos-age-key"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# Re-exec inside nix shell if bw is not available
if ! command -v bw &> /dev/null; then
    info "Bitwarden CLI not found, entering nix shell..."
    SCRIPT_PATH="$(readlink -f "$0")"
    exec nix shell nixpkgs#bitwarden-cli --command bash "$SCRIPT_PATH" "$@"
fi

# Check if already bootstrapped
if [ -f "$AGE_KEY_PATH" ]; then
    warn "Age key already exists at $AGE_KEY_PATH"
    read -rp "Overwrite? [y/N] " confirm
    if [[ ! "$confirm" =~ ^[yY]$ ]]; then
        info "Aborted."
        exit 0
    fi
fi

# Login to Bitwarden if no session
if [ -z "${BW_SESSION:-}" ]; then
    info "Logging into Bitwarden..."
    
    # Check if already logged in
    if bw status 2>/dev/null | grep -q '"status":"locked"'; then
        info "Vault is locked, unlocking..."
        BW_SESSION=$(bw unlock --raw)
    elif bw status 2>/dev/null | grep -q '"status":"unauthenticated"'; then
        BW_SESSION=$(bw login --raw)
    else
        info "Already unlocked."
        BW_SESSION=$(bw unlock --raw 2>/dev/null || bw login --raw)
    fi
    
    export BW_SESSION
fi

# Sync vault
info "Syncing Bitwarden vault..."
bw sync

# Fetch the age key
info "Fetching age master key from Bitwarden (item: '$BW_ITEM_NAME')..."
AGE_KEY=$(bw get notes "$BW_ITEM_NAME" 2>/dev/null) || {
    error "Could not find Bitwarden item '$BW_ITEM_NAME'"
    error ""
    error "Create it in Bitwarden as a Secure Note with the content of your age private key:"
    error "  # created: $(date +%Y-%m-%d)"
    error "  # public key: age1d2naq9lhxytel2m4m5mfqlkwyv5yp36798hekgc2nnc3tcn43u3q0rm5ps"
    error "  AGE-SECRET-KEY-1XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    exit 1
}

# Validate it looks like an age key
if ! echo "$AGE_KEY" | grep -q "AGE-SECRET-KEY-"; then
    error "Retrieved content doesn't look like an age private key."
    error "Ensure the Bitwarden Secure Note '$BW_ITEM_NAME' contains lines like:"
    error "  AGE-SECRET-KEY-1XXXXXX..."
    exit 1
fi

# Write the key
info "Writing age key to $AGE_KEY_PATH..."
sudo mkdir -p "$(dirname "$AGE_KEY_PATH")"
echo "$AGE_KEY" | sudo tee "$AGE_KEY_PATH" > /dev/null
sudo chmod 600 "$AGE_KEY_PATH"
sudo chown root:root "$AGE_KEY_PATH"

# Logout from Bitwarden
info "Locking Bitwarden vault..."
bw lock > /dev/null 2>&1 || true

info ""
info "Age master key installed at $AGE_KEY_PATH"
info ""
info "Next steps:"
info "  1. Encrypt your secrets (if not already done):"
info "     cd ~/.setup && nix run github:ryantm/agenix -- -e secrets/ssh_private_key.age"
info "  2. Rebuild NixOS:"
info "     sudo nixos-rebuild switch --flake ~/.setup"
