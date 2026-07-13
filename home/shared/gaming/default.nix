{config, lib, pkgs, ...} :
with lib;
let
  gaming = config.gaming;   
in {
    
  options = {
    gaming = {
      enable = lib.mkEnableOption "Gaming support";
      gameLocations = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Filesystem paths to expose to gaming Flatpak apps (Heroic, Lutris, Bottles).";
        example = [ "/mnt/LinuxGames/" "/run/media/qboileau/games/" ];
      };
    };
  };
  
  config = mkIf gaming.enable {
    # lutris, bottles and heroic installed via Flatpak to avoid FHS-env local builds.
    services.flatpak.packages = [
      { appId = "net.lutris.Lutris"; origin = "flathub"; }
      { appId = "com.usebottles.bottles"; origin = "flathub"; }
      { appId = "com.heroicgameslauncher.hgl"; origin = "flathub"; }
    ];

    # nix-flatpak v0.7.0 has no `branch` field, so it can't express the versioned
    # `runtime/org.freedesktop.Platform.VulkanLayer.<x>/x86_64/25.08` refs.
    # Listing these VulkanLayer *runtimes* as bare appIds in the declarative package
    # list makes `flatpak-managed-install.service` fail every boot with
    #   "No ref chosen to resolve matches for 'org.freedesktop.Platform.VulkanLayer.*'"
    # because the ref is ambiguous without a branch. Install them via activation
    # scripts instead — idempotent, exact CLI control.
    # 25.08 must match Heroic's platform runtime (org.freedesktop.Platform/25.08).
    # To check: flatpak info com.heroicgameslauncher.hgl | grep Runtime
    home.activation.installMangoHudVulkanLayer = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if ! ${pkgs.flatpak}/bin/flatpak --user info org.freedesktop.Platform.VulkanLayer.MangoHud//25.08 &>/dev/null; then
        $DRY_RUN_CMD ${pkgs.flatpak}/bin/flatpak install --user -y --noninteractive \
          flathub runtime/org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/25.08
      fi
    '';

    home.activation.installGamescopeVulkanLayer = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if ! ${pkgs.flatpak}/bin/flatpak --user info org.freedesktop.Platform.VulkanLayer.gamescope//25.08 &>/dev/null; then
        $DRY_RUN_CMD ${pkgs.flatpak}/bin/flatpak install --user -y --noninteractive \
          flathub runtime/org.freedesktop.Platform.VulkanLayer.gamescope/x86_64/25.08
      fi
    '';

    home.activation.installVkBasaltVulkanLayer = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if ! ${pkgs.flatpak}/bin/flatpak --user info org.freedesktop.Platform.VulkanLayer.vkBasalt//25.08 &>/dev/null; then
        $DRY_RUN_CMD ${pkgs.flatpak}/bin/flatpak install --user -y --noninteractive \
          flathub runtime/org.freedesktop.Platform.VulkanLayer.vkBasalt/x86_64/25.08
      fi
    '';

    # Expose game library paths + NixOS host binaries to all three gaming Flatpak apps.
    # - /nix/:ro and /run/current-system/sw/bin/:ro make mangohud, gamemoderun, etc. reachable.
    # - PATH override ensures Heroic/Lutris/Bottles find them when launching games.
    services.flatpak.overrides =
      let
        perAppOverride = {
          Context.filesystems = gaming.gameLocations;
        };
      in
        lib.genAttrs
          [ "com.heroicgameslauncher.hgl" "net.lutris.Lutris" "com.usebottles.bottles" ]
          (_: perAppOverride);

    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.mangohud.enable
    programs.mangohud = {
        enable = true;
        package = pkgs.unstable.mangohud;
    };

    home.sessionVariables = {
      MESA_SHADER_CACHE_MAX_SIZE = "12G"; # default to 1G, but some games need more
    };

    home.packages = with pkgs; [
        unstable.goverlay
        owmods-gui # https://outerwildsmods.com/mod-manager/
    ];

    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.discord.enable
    #programs.discord.enable = true;
  };
}
