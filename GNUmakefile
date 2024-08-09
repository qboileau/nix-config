
HOSTNAME := $(shell hostname)


.PHONY: install
install: 
	@echo "Download disk configuration from github"
	curl https://raw.githubusercontent.com/qboileau/nix-config/main/nixos/vm/disks.nix -o /tmp/disks.nix

	@echo "Format disk"
	sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/disks.nix
	mount | grep /mnt

	@echo "Install from github flake"
	nixos-install --flake https://github.com/qboileau/nix-config#vm


.PHONY: update-system
update-system:
	sudo nixos-rebuild switch --flake ".#$(HOSTNAME)"

.PHONY: update-home
update-home:
	@echo ".#$(HOSTNAME)@${USER}"
	home-manager switch --flake ".#${USER}@$(HOSTNAME)"