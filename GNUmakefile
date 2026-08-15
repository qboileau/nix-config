
HOSTNAME := $(shell hostname)
BUILD_JOBS := 5
BUILD_CORES := 10
CACHE_URLS := "https://cache.nixos.org https://nix-community.cachix.org"
CACHE_KEYS := "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="

# Pass GitHub token to Nix to avoid API rate-limiting when fetching flake inputs.
# Set GITHUB_TOKEN in your shell environment before running make.
ifdef GITHUB_TOKEN
  NIX_CONFIG := access-tokens = github.com=$(GITHUB_TOKEN)
  export NIX_CONFIG
endif

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
	sudo NIX_CONFIG="$(NIX_CONFIG)" NIXOS_LABEL="$(TAG)" nixos-rebuild switch --flake ".#$(HOSTNAME)" --use-remote-sudo --show-trace \
		--option substituters $(CACHE_URLS) \
		--option trusted-public-keys $(CACHE_KEYS) \
		--max-jobs $(BUILD_JOBS) --cores $(BUILD_CORES)
else
	sudo NIX_CONFIG="$(NIX_CONFIG)" nixos-rebuild switch --flake ".#$(HOSTNAME)" --use-remote-sudo --show-trace \
		--option substituters $(CACHE_URLS) \
		--option trusted-public-keys $(CACHE_KEYS) \
		--max-jobs $(BUILD_JOBS) --cores $(BUILD_CORES)
endif

.PHONY: test-system
test-system: ## Test NixOS configuration (use TAG=mytag to label the generation in boot menu)
ifdef TAG
	sudo NIX_CONFIG="$(NIX_CONFIG)" NIXOS_LABEL="$(TAG)" nixos-rebuild test --flake ".#$(HOSTNAME)" --use-remote-sudo --show-trace \
		--option substituters $(CACHE_URLS) \
		--option trusted-public-keys $(CACHE_KEYS) \
		--max-jobs $(BUILD_JOBS) --cores $(BUILD_CORES)
else
	sudo NIX_CONFIG="$(NIX_CONFIG)" nixos-rebuild test --flake ".#$(HOSTNAME)" --use-remote-sudo --show-trace \
		--option substituters $(CACHE_URLS) \
		--option trusted-public-keys $(CACHE_KEYS) \
		--max-jobs $(BUILD_JOBS) --cores $(BUILD_CORES)
endif

.PHONY: restart-display
restart-display: ## Restart display manager (use if test-system kills your session)
	sudo systemctl restart display-manager.service

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

.PHONY: list-generations
list-generations: ## List NixOS system + home-manager generations with their closure size on disk
	./scripts/list-generations.sh

.PHONY: gc-estimate
gc-estimate: ## Estimate reclaimable space from deleting old system + home-manager generations
	./scripts/gc-estimate.sh

.PHONY: gc
gc: ## Delete old system + home-manager generations and collect garbage (needs sudo)
	sudo nix-collect-garbage -d
