{
  description = "My everything nixos configuration";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    # Unstable channel used in overlay.
    # Uses the channel URL (not the git branch) so nix flake update always picks
    # a commit that Hydra has finished building — never raw uncached branch HEAD.
    nixpkgs-unstable.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    systems.url = "github:nix-systems/default-linux";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    #Disko
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Nixos hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    auto-cpufreq.url = "github:AdnanHodzic/auto-cpufreq";
    auto-cpufreq.inputs.nixpkgs.follows = "nixpkgs";

    # https://github.com/brumhard/krewfile
    krewfile.url = "github:brumhard/krewfile"; 
    krewfile.inputs.nixpkgs.follows = "nixpkgs";

    # BISECT (grim/screencopy stale-buffer regression, commit 41356f8): pin Hyprland to the
    # last known-good 0.54.3, taken from the pre-26.05 unstable rev, while keeping the new
    # Mesa/kernel. Wired into home/shared/desktop/hyprland/default.nix. Remove to revert.
    nixpkgs-hyprland-054.url = "github:nixos/nixpkgs/da5ad661ba4e5ef59ba743f0d112cbc30e474f32";

    #hyprland.url = "github:hyprwm/Hyprland?submodules=1&ref=refs/tags/v0.54.2";
    #https://github.com/outfoxxed/hy3
    # hy3.url = "github:outfoxxed/hy3"; 
    # hy3.inputs.hyprland.follows = "hyprland";
    #hyprqt6engine.url = "github:hyprwm/hyprqt6engine";
    #hyprqt6engine.inputs.nixpkgs.follows = "nixpkgs";

    # ironbar.url = "github:JakeStanger/ironbar";
    # ironbar.inputs.nixpkgs.follows = "nixpkgs";

    noctalia.url = "github:noctalia-dev/noctalia-shell";
    noctalia.inputs.nixpkgs.follows = "nixpkgs";
    
    nixos-loading-plymouth.url = "github:qboileau/nixos-load-plymouth";
    nixos-loading-plymouth.inputs.nixpkgs.follows = "nixpkgs";

    # qbz.url = "github:vicrodh/qbz?ref=refs/tags/v1.2.4";
    qbz.url = "github:qboileau/qbz/feature/external/nix-flake-direct-input-install";
    qbz.inputs.nixpkgs.follows = "nixpkgs";

    # Secrets management
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    # Declarative Flatpak management https://github.com/gmodena/nix-flatpak
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.7.0";
  };

  outputs = {
    self,
    nixpkgs,
    systems,
    home-manager,
    disko,
    nixos-hardware,
    nix-flatpak,
    auto-cpufreq,
    krewfile,
    # hyprland, # now using pkgs.unstable.hyprland
    # hyprqt6engine, # now using pkgs.unstable.hyprland-qt-support
    # hy3, # now using pkgs.unstable.hyprlandPlugins.hy3
    # ironbar,
    noctalia,
    nixos-loading-plymouth,
    qbz,
    agenix,
    ...
  } @ inputs: 
  let
    inherit (self) outputs;
    
    lib = nixpkgs.lib // home-manager.lib;
    configLib = import ./lib { inherit lib; };

    # Supported systems for your flake packages, shell, etc.
    username = "qboileau";

    forEachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});
    pkgsFor = lib.genAttrs (import systems) (
      system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
    );

    hostsSettings = {
        framework = {
           users = [ "${username}" ];
        };
        desktop = {
           users = [ "${username}" ];
        };
    };
    forAllHosts = builtins.attrNames hostsSettings;

    specialArgs = {
      inherit inputs outputs configLib nixpkgs username;
    };
  in {
    inherit lib;

    packages = forEachSystem (pkgs: import ./pkgs (pkgs.extend outputs.overlays.unstable-packages));
    formatter = forEachSystem (pkgs: pkgs.alejandra);

    # Custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs outputs;};
    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      framework = nixpkgs.lib.nixosSystem {
        specialArgs = specialArgs // {
          hostUsers = hostsSettings.framework.users;
        };
        modules = [
          ./nixos/framework/configuration.nix
          disko.nixosModules.disko
          nixos-hardware.nixosModules.framework-11th-gen-intel
          auto-cpufreq.nixosModules.default
          agenix.nixosModules.default
          nixos-loading-plymouth.nixosModules.default
          home-manager.nixosModules.default
          {
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.useGlobalPkgs = true;
            home-manager.backupFileExtension = "bak";
            home-manager.sharedModules = [
              krewfile.homeManagerModules.krewfile
              nix-flatpak.homeManagerModules.nix-flatpak
              # ironbar.homeManagerModules.default
            ];
            home-manager.useUserPackages = true;
            home-manager.users.${username} = import ./home/qboileau/framework.nix;
          }
        ];
      };
      framework-amd = nixpkgs.lib.nixosSystem {
        specialArgs = specialArgs // {
          hostUsers = hostsSettings.framework.users;
        };
        modules = [
          ./nixos/framework-amd/configuration.nix
          disko.nixosModules.disko
          nixos-hardware.nixosModules.framework-amd-ai-300-series
          auto-cpufreq.nixosModules.default
          agenix.nixosModules.default
          nixos-loading-plymouth.nixosModules.default
          home-manager.nixosModules.default
          {
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.useGlobalPkgs = true;
            home-manager.backupFileExtension = "bak";
            home-manager.sharedModules = [
              krewfile.homeManagerModules.krewfile
              nix-flatpak.homeManagerModules.nix-flatpak
              # ironbar.homeManagerModules.default
            ];
            home-manager.useUserPackages = true;
            home-manager.users.${username} = import ./home/qboileau/framework-amd.nix;
          }
        ];
      };
      desktop = nixpkgs.lib.nixosSystem {
        specialArgs = specialArgs // {
          hostUsers = hostsSettings.desktop.users;
        };
        modules = [
          ./nixos/desktop/configuration.nix
          agenix.nixosModules.default
          home-manager.nixosModules.default
          nixos-loading-plymouth.nixosModules.default
          {
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.useGlobalPkgs = true;
            home-manager.backupFileExtension = "bak";
            home-manager.sharedModules = [
              krewfile.homeManagerModules.krewfile
              nix-flatpak.homeManagerModules.nix-flatpak
              # ironbar.homeManagerModules.default
              noctalia.homeModules.default
            ];
            home-manager.useUserPackages = true;
            home-manager.users.${username} = import ./home/qboileau/desktop.nix;
          }
        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
    };
  };
}
