
HOSTNAME := $(shell hostname)

.PHONY: help
help: ## Prints help for targets with comments
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: update-inputs
update-inputs: ## Update flake inputs
	nix flake update

.PHONY: update-input
update-input: ## Update a single flake input (e.g., make update-input INPUT=nixpkgs)
	nix flake update $(INPUT)

.PHONY: update-system
update-system: ## Update NixOS configuration (use TAG=mytag to label the generation in boot menu)
ifdef TAG
	sudo NIXOS_LABEL="$(TAG)" nixos-rebuild switch --flake ".#$(HOSTNAME)" --use-remote-sudo --show-trace
else
	sudo nixos-rebuild switch --flake ".#$(HOSTNAME)" --use-remote-sudo --show-trace
endif

.PHONY: test-system
test-system: ## Test NixOS configuration (use TAG=mytag to label the generation in boot menu)
ifdef TAG
	sudo NIXOS_LABEL="$(TAG)" nixos-rebuild test --flake ".#$(HOSTNAME)" --use-remote-sudo --show-trace
else
	sudo nixos-rebuild test --flake ".#$(HOSTNAME)" --use-remote-sudo --show-trace
endif

.PHONY: update-home
update-home: ## Update Home Manager configuration
	@echo ".#$(HOSTNAME)@${USER}"
	home-manager switch --flake ".#${USER}@$(HOSTNAME)" #--show-trace -b "bkp"

revert-home: ## Revert to previous
	home-manager generations
	home-manager switch --rollback

.PHONY: secrets-bootstrap
secrets-bootstrap: ## Bootstrap age master key from Bitwarden vault (first-time setup)
	./scripts/bootstrap-secrets.sh

.PHONY: secrets-update
secrets-update: ## Encrypt secrets from live system into secrets/*.age (CATEGORIES="ssh gpg git shell network bluetooth")
ifdef CATEGORIES
	./scripts/update-secrets.sh $(CATEGORIES)
else
	./scripts/update-secrets.sh
endif

.PHONY: secrets-rekey
secrets-rekey: ## Re-encrypt all .age files after changing keys in secrets/secrets.nix
	cd secrets && nix run github:ryantm/agenix -- --rekey -i /var/lib/age/key.txt

.PHONY: enable-git-hooks
enable-git-hooks: ## Enable Git hooks from .githooks directory
	git config --local core.hooksPath .githooks

.PHONY: lint
lint: ## Run linting checks
	statix check ./

.PHONY: fix
fix: ## Fix linting issues
	statix fix ./

.PHONY: check-option
check-option: ## Check a NixOS option value (e.g., make check-option OPT=services.nginx.enable)
	nixos-option -F . $(OPT)
