{
  description = "My everything nixos configuration";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    # Unstable channel used in overlay
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default-linux";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-25.11";
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

    hyprland.url = "github:hyprwm/Hyprland?submodules=1&tag=v0.52.1";
    #https://github.com/outfoxxed/hy3
    # hy3.url = "github:outfoxxed/hy3"; 
    # hy3.inputs.hyprland.follows = "hyprland";

    ironbar.url = "github:JakeStanger/ironbar";
    ironbar.inputs.nixpkgs.follows = "nixpkgs";

    noctalia.url = "github:noctalia-dev/noctalia-shell";
    noctalia.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    systems,
    home-manager,
    disko,
    nixos-hardware,
    auto-cpufreq,
    krewfile,
    hyprland,
    # hy3,
    ironbar,
    noctalia,
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

    packages = forEachSystem (pkgs: import ./pkgs {inherit pkgs;});
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
        ];
      };
      desktop = nixpkgs.lib.nixosSystem {
        specialArgs = specialArgs // {
          hostUsers = hostsSettings.desktop.users;
        };
        modules = [
          ./nixos/desktop/configuration.nix
          home-manager.nixosModules.default
          {
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.useGlobalPkgs = true;
            home-manager.backupFileExtension = "bak";
            home-manager.sharedModules = [
              ironbar.homeManagerModules.default
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
      "${username}@framework" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; 
        extraSpecialArgs = specialArgs;
        modules = [ 
          ./home/qboileau/framework.nix 
          krewfile.homeManagerModules.krewfile
          ironbar.homeManagerModules.default
        ];
      };
    };
  };
}
