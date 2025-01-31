
HOSTNAME := $(shell hostname)

.PHONY: help
help: ## Prints help for targets with comments
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: update-system
update-system:
	sudo nixos-rebuild switch --flake ".#$(HOSTNAME)"

.PHONY: update-home
update-home:
	@echo ".#$(HOSTNAME)@${USER}"
	home-manager switch --flake ".#${USER}@$(HOSTNAME)"

.PHONY: enable-git-hooks
enable-git-hooks:
	git config --local core.hooksPath .githooks

.PHONY: lint
lint:
	statix check ./

.PHONY: fix
fix:
	statix fix ./