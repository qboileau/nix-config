#!/usr/bin/env bash
# update-secrets.sh
# Encrypt local secret files into agenix .age format.
# Run this whenever you add/update SSH keys, GPG keys, wifi, bluetooth, etc.
# Uses the agenix CLI which reads secrets.nix for per-secret recipient lists.
#
# Usage:
#   ./scripts/update-secrets.sh          # Encrypt all secret categories
#   ./scripts/update-secrets.sh ssh      # Only encrypt SSH secrets
#   ./scripts/update-secrets.sh gpg git shell network bluetooth

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SECRETS_DIR="$REPO_DIR/secrets"
RULES_FILE="$SECRETS_DIR/secrets.nix"
AGE_KEY="/var/lib/age/key.txt"
HOME_DIR="/home/${USER}"
HOSTNAME="$(hostname)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()    { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }
section() { echo -e "\n${CYAN}=== $* ===${NC}"; }

# Ensure age key exists
if [ ! -f "$AGE_KEY" ]; then
    error "Age key not found at $AGE_KEY"
    error "Run ./scripts/bootstrap-secrets.sh first"
    exit 1
fi

# agenix command — use flake-based invocation
AGENIX_CMD="nix run github:ryantm/agenix --"

# Run agenix from inside SECRETS_DIR (agenix resolves .age paths relative to cwd)
run_agenix() {
    (cd "$SECRETS_DIR" && "$@")
}

# Encrypt a file using agenix STDIN piping.
# When STDIN is not interactive, agenix sets EDITOR="cp /dev/stdin" automatically.
# For existing .age files, agenix needs -i to decrypt first, so we use sudo.
agenix_encrypt() {
    local src="$1"
    local age_file="$2"  # relative to secrets dir, e.g. ssh/pro_id_rsa.age

    if [ ! -f "$src" ]; then
        warn "Source not found, skipping: $src"
        return 1
    fi

    mkdir -p "$SECRETS_DIR/$(dirname "$age_file")"

    if [ -f "$SECRETS_DIR/$age_file" ]; then
        cat "$src" | (cd "$SECRETS_DIR" && sudo RULES="$RULES_FILE" $AGENIX_CMD -e "$age_file" -i "$AGE_KEY")
    else
        cat "$src" | (cd "$SECRETS_DIR" && RULES="$RULES_FILE" $AGENIX_CMD -e "$age_file")
    fi
    info "Encrypted: $src → secrets/$age_file"
}

# Encrypt a directory as a tarball, then encrypt with agenix
agenix_encrypt_dir() {
    local src="$1"
    local age_file="$2"

    if [ ! -d "$src" ]; then
        warn "Directory not found, skipping: $src"
        return 1
    fi

    mkdir -p "$SECRETS_DIR/$(dirname "$age_file")"

    if [ -f "$SECRETS_DIR/$age_file" ]; then
        tar cf - -C "$(dirname "$src")" "$(basename "$src")" | (cd "$SECRETS_DIR" && sudo RULES="$RULES_FILE" $AGENIX_CMD -e "$age_file" -i "$AGE_KEY")
    else
        tar cf - -C "$(dirname "$src")" "$(basename "$src")" | (cd "$SECRETS_DIR" && RULES="$RULES_FILE" $AGENIX_CMD -e "$age_file")
    fi
    info "Encrypted dir: $src → secrets/$age_file"
}

# Encrypt a sudo-required directory as tarball
agenix_encrypt_sudo_dir() {
    local src="$1"
    local age_file="$2"

    if ! sudo test -d "$src" 2>/dev/null; then
        warn "Directory not found (sudo), skipping: $src"
        return 1
    fi

    mkdir -p "$SECRETS_DIR/$(dirname "$age_file")"

    if [ -f "$SECRETS_DIR/$age_file" ]; then
        sudo tar cf - -C "$(dirname "$src")" "$(basename "$src")" | (cd "$SECRETS_DIR" && sudo RULES="$RULES_FILE" $AGENIX_CMD -e "$age_file" -i "$AGE_KEY")
    else
        sudo tar cf - -C "$(dirname "$src")" "$(basename "$src")" | (cd "$SECRETS_DIR" && RULES="$RULES_FILE" $AGENIX_CMD -e "$age_file")
    fi
    info "Encrypted dir: $src → secrets/$age_file"
}

# Resolve symlinks (home-manager managed files point to nix store)
resolve_file() {
    local path="$1"
    if [ -L "$path" ]; then
        readlink -f "$path"
    else
        echo "$path"
    fi
}

# ============================================================
# Secret categories
# ============================================================

do_ssh() {
    section "SSH Keys & Config"
    agenix_encrypt "$HOME_DIR/.ssh/pro_id_rsa"     "ssh/pro_id_rsa.age"
    agenix_encrypt "$HOME_DIR/.ssh/pro_id_rsa.pub" "ssh/pro_id_rsa.pub.age"
    agenix_encrypt "$HOME_DIR/.ssh/config"         "ssh/config.age"

    # Auto-detect additional SSH keys
    for key in "$HOME_DIR"/.ssh/id_* "$HOME_DIR"/.ssh/*_id_*; do
        [ -f "$key" ] || continue
        local basename
        basename=$(basename "$key")
        # Skip already handled and known_hosts
        [[ "$basename" == "pro_id_rsa" || "$basename" == "pro_id_rsa.pub" ]] && continue
        [[ "$basename" == known_hosts* ]] && continue
        warn "Found additional SSH key not in secrets.nix: $basename"
        warn "  Add \"ssh/$basename.age\".publicKeys = allKeys; to secrets/secrets.nix"
        warn "  Then re-run this script"
    done
}

do_gpg() {
    section "GPG Keys"

    local gpg_tmp
    gpg_tmp=$(mktemp -d)
    trap "rm -rf '$gpg_tmp'" RETURN

    # Export secret keys (armored)
    gpg --batch --yes --armor --export-secret-keys > "$gpg_tmp/secret-keys.asc"
    if [ -s "$gpg_tmp/secret-keys.asc" ]; then
        agenix_encrypt "$gpg_tmp/secret-keys.asc" "gpg/secret-keys.asc.age"
    else
        warn "No GPG secret keys found, skipping"
    fi

    # Export public keys (armored)
    gpg --batch --yes --armor --export > "$gpg_tmp/public-keys.asc"
    if [ -s "$gpg_tmp/public-keys.asc" ]; then
        agenix_encrypt "$gpg_tmp/public-keys.asc" "gpg/public-keys.asc.age"
    else
        warn "No GPG public keys found, skipping"
    fi

    # Export ownertrust
    gpg --batch --yes --export-ownertrust > "$gpg_tmp/ownertrust.txt"
    if [ -s "$gpg_tmp/ownertrust.txt" ]; then
        agenix_encrypt "$gpg_tmp/ownertrust.txt" "gpg/ownertrust.txt.age"
    else
        warn "No GPG ownertrust found, skipping"
    fi
}

do_git() {
    section "Git Configs (with credentials/signing keys)"

    # Personal git config — shared across all hosts
    local personal
    personal=$(resolve_file "$HOME_DIR/.config/git/personal")
    [ -f "$personal" ] && agenix_encrypt "$personal" "git/personal.age"

    # Per-host git configs (work, conduktor, etc.)
    for name in work conduktor; do
        local conf
        conf=$(resolve_file "$HOME_DIR/.config/git/$name")
        if [ -f "$conf" ]; then
            agenix_encrypt "$conf" "git/$HOSTNAME/${name}.age"
        fi
    done

    # Git credentials file
    if [ -f "$HOME_DIR/.git-credentials" ]; then
        agenix_encrypt "$HOME_DIR/.git-credentials" "git/credentials.age"
    fi
}

do_shell() {
    section "Shell Secrets (.bashrc.d → $HOSTNAME)"

    # Encrypt files in .bashrc.d into per-host dir.
    # - Skip home-manager symlinks (resolve into /nix/store, managed declaratively).
    # - Follow agenix symlinks (resolve into /run/agenix*) so live edits are re-encrypted.
    for f in "$HOME_DIR"/.bashrc.d/*; do
        [ -f "$f" ] || continue
        local basename src
        basename=$(basename "$f")
        src="$f"
        if [ -L "$f" ]; then
            local target
            target=$(readlink -f "$f")
            if [[ "$target" == /nix/store/* ]]; then
                continue
            fi
            src="$target"
        fi
        agenix_encrypt "$src" "shell/$HOSTNAME/${basename}.age"
    done
}

do_network() {
    section "NetworkManager Connections ($HOSTNAME)"
    agenix_encrypt_sudo_dir "/etc/NetworkManager/system-connections" "network/$HOSTNAME/connections.tar.age"
}

do_bluetooth() {
    section "Bluetooth Pairings ($HOSTNAME)"
    if sudo test -d "/var/lib/bluetooth" 2>/dev/null; then
        agenix_encrypt_sudo_dir "/var/lib/bluetooth" "bluetooth/$HOSTNAME/devices.tar.age"
    else
        warn "No bluetooth directory found"
    fi
}

# ============================================================
# Main
# ============================================================

# Parse categories to update (default: all)
CATEGORIES=("${@:-ssh gpg git shell network bluetooth}")
if [ $# -eq 0 ]; then
    CATEGORIES=(ssh gpg git shell network bluetooth)
fi

info "Encrypting secrets from live system into $SECRETS_DIR/"
info "Using age key: $AGE_KEY"
info "Categories: ${CATEGORIES[*]}"

for cat in "${CATEGORIES[@]}"; do
    case "$cat" in
        ssh)       do_ssh ;;
        gpg)       do_gpg ;;
        git)       do_git ;;
        shell)     do_shell ;;
        network)   do_network ;;
        bluetooth) do_bluetooth ;;
        all)       do_ssh; do_gpg; do_git; do_shell; do_network; do_bluetooth ;;
        *)         error "Unknown category: $cat"; exit 1 ;;
    esac
done

echo ""
info "Done! Encrypted secrets are in: secrets/"
info ""
info "Next steps:"
info "  1. Review changes:  git -C $REPO_DIR diff --stat"
info "  2. Stage:           git -C $REPO_DIR add secrets/"
info "  3. Commit:          git -C $REPO_DIR commit -m 'secrets: update encrypted files'"
info "  4. Rebuild:         sudo nixos-rebuild switch --flake $REPO_DIR"
