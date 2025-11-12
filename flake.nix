{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-25.05";
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

    hyprland.url = "github:hyprwm/Hyprland";
    # hy3.url = "github:outfoxxed/hy3?ref=hl{version}"; # where {version} is the hyprland release version
    # # or "github:outfoxxed/hy3" to follow the development branch.
    # # (you may encounter issues if you dont do the same for hyprland)
    # hy3.inputs.hyprland.follows = "hyprland";

  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    disko,
    nixos-hardware,
    auto-cpufreq,
    krewfile,
    hyprland,
    ...
  } @ inputs: 
  let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    username = "qboileau";
    systems = [ "x86_64-linux" ];

    forAllSystems = nixpkgs.lib.genAttrs systems;

    hostsSettings = {
        framework = {
           users = [ "${username}" ];
        };
        home = {
           users = [ "${username}" ];
        };
    };
    forAllHosts = builtins.attrNames hostsSettings;
    inherit (nixpkgs) lib;
    configLib = import ./lib { inherit lib; };
    specialArgs = {
      inherit inputs outputs configLib nixpkgs username;
    };
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
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
      home = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = specialArgs // {
          hostUsers = hostsSettings.home.users;
        };
        modules = [
          ./nixos/desktop/configuration.nix
          home-manager.nixosModules.default
          {
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.useGlobalPkgs = true;
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
        ];
      };
      # "${username}@home" = home-manager.lib.homeManagerConfiguration {
      #   pkgs = nixpkgs.legacyPackages.x86_64-linux;
      #   extraSpecialArgs = specialArgs;
      #   modules = [
      #     ./home/qboileau/desktop.nix
      #   ];
      # };
    };
  };
}
