
HOSTNAME := $(shell hostname)


.PHONY: update-system
update-system:
	sudo nixos-rebuild switch --flake ".#$(HOSTNAME)"

.PHONY: update-home
update-home:
	@echo ".#$(HOSTNAME)@${USER}"
	home-manager switch --flake ".#${USER}@$(HOSTNAME)"