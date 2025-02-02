#!/bin/bash

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
echo "Format disk using ./nixos/$HOSTNAME/disks.nix"
read -p "Are you sure? (Y/n)" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./nixos/$HOSTNAME/disks.nix
fi

mount | grep /mnt

echo "Install nixOs"
nixos-install --flake .#$HOSTNAME

echo "Create user setup dir"
nixos-enter -c "su -c 'git clone https://github.com/qboileau/nix-config /home/qboileau/.setup' qboileau"

echo "You can now reboot"