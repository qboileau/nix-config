
HOSTNAME := $(shell hostname)

.PHONY: help
help: ## Prints help for targets with comments
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


.PHONY: upgrade-system
upgrade-system:
	sudo nix-channel --add https://channels.nixos.org/nixos-25.05 nixos
	sudo nixos-rebuild switch --upgrade --flake ".#$(HOSTNAME)" --use-remote-sudo -p upgrade-25.05

.PHONY: update-inputs
update-inputs:
	nix flake update

.PHONY: update-system
update-system:
	sudo nixos-rebuild switch --flake ".#$(HOSTNAME)" --use-remote-sudo --show-trace

.PHONY: test-system
test-system:
	sudo nixos-rebuild test --flake ".#$(HOSTNAME)" --use-remote-sudo --show-trace

.PHONY: update-home
update-home:
	@echo ".#$(HOSTNAME)@${USER}"
	home-manager switch --flake ".#${USER}@$(HOSTNAME)" #--show-trace -b "bkp"

.PHONY: enable-git-hooks
enable-git-hooks:
	git config --local core.hooksPath .githooks

.PHONY: lint
lint:
	statix check ./

.PHONY: fix
fix:
	statix fix ./
