
HOSTNAME := $(shell hostname)


.PHONY: update-system
update-system:
	sudo nixos-rebuild switch --flake ".#$(HOSTNAME)"

.PHONY: update-home
update-home:
	@echo ".#$(HOSTNAME)@${USER}"
	home-manager switch --flake ".#${USER}@$(HOSTNAME)"

.PHONY: enable-git-hooks
enable-git-hooks:
	git config --local include.path ./.gitconfig

.PHONY: lint
lint:
	statix check ./

.PHONY: fix
fix:
	statix fix ./