#!/usr/bin/env bash

set -eu

HOSTNAME=${1:?Missing target HOSTNAME}
TMP_SOURCE_DIR=$(mktemp -d)

check_command(){
    if ! command -v "${1}" &> /dev/null
    then
        echo "${1} could not be found"
        exit 1
    fi
}

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

check_command nix
check_command git
check_command nixos-install

mkdir -p "$TMP_SOURCE_DIR"

git clone https://github.com/qboileau/nix-config "$TMP_SOURCE_DIR"

cd "$TMP_SOURCE_DIR"

# Check if /mnt is already mounted (resume after failure)
if mount | grep -q " on /mnt"; then
    echo "✓ /mnt is already mounted, skipping disk formatting"
    mount | grep " on /mnt"
else
    echo "Format disk using ./nixos/$HOSTNAME/disks.nix"
    read -p "Are you sure? (Y/n)" -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./nixos/$HOSTNAME/disks.nix
    else
        echo "Disk formatting aborted"
        exit 1
    fi
    mount | grep " on /mnt"
fi

# Check if master key already exists
if [ -f /mnt/var/lib/age/key.txt ]; then
    echo "✓ Master age key already exists in /mnt/var/lib/age/key.txt, skipping bootstrap"
elif [ -f /var/lib/age/key.txt ]; then
    echo "✓ Master age key found in /var/lib/age/key.txt, copying to target"
    mkdir -p /mnt/var/lib/age
    cp /var/lib/age/key.txt /mnt/var/lib/age/key.txt
    chmod 600 /mnt/var/lib/age/key.txt
else
    echo "Bootstrap age master key for agenix secrets"
    echo "This will prompt for your Bitwarden credentials"
    ./scripts/bootstrap-secrets.sh
    # Copy master key to target system
    mkdir -p /mnt/var/lib/age
    cp /var/lib/age/key.txt /mnt/var/lib/age/key.txt
    chmod 600 /mnt/var/lib/age/key.txt
fi

echo "Install nixOs"
nixos-install --flake .#$HOSTNAME --no-root-password

echo "Set User password"
nixos-enter -c "su -c 'passwd qboileau'"

echo "Create user setup dir"
nixos-enter -c "su -c 'git clone https://github.com/qboileau/nix-config /home/qboileau/.setup' qboileau"

echo "You can now reboot"
