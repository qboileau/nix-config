{config, pkgs, lib,inputs, ...} :
with lib;
let
  # Pre-wired FALLBACK to known-good Hyprland 0.54.3 (pre-26.05 unstable rev), for the RDNA4
  # HDR flicker + screencopy corruption bug (Hyprland #14845) on RX 9070 XT. 0.54 predates the
  # broken 0.55 HDR render path. Currently INACTIVE (package lines below use pkgs.unstable =
  # 0.55.4); activate by swapping the three package lines to their hyprland054.* variants.
  # See memory hyprland-rdna4-screencopy-stale.
  hyprland054 = inputs.nixpkgs-hyprland-054.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{

  options = {
    hyprland = {
      autolock = {
        enable = lib.mkEnableOption "Enable Hyprland lock support";
      };
      autostart = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "List of applications to autostart with Hyprland";
      };
      bar = lib.mkOption {
        type = lib.types.enum [
          "waybar"
          "ironbar"
        ];
        default = "waybar";
        description = "Select the bar to use with Hyprland. Either waybar or ironbar";
      };
      configType = lib.mkOption {
        type = lib.types.enum [
          "hyprlang"
          "lua"
        ];
        default = "hyprlang";
        description = ''
          Which config format to generate for Hyprland itself. "hyprlang" writes
          hyprland.conf from ./hyprlang, "lua" writes hyprland.lua from ./lua. The two are
          kept in sync so this is a straight swap; hyprlang is removed in Hyprland 0.57.

          NOTE hyprland.lua takes priority over hyprland.conf, so a leftover hyprland.lua
          in ~/.config/hypr keeps winning after switching back — remove it by hand.

          Verify before switching sessions, a lua error voids the ENTIRE config:
            Hyprland --verify-config -c "$(nix build --no-link --print-out-paths \
              '.#nixosConfigurations.desktop.config.home-manager.users.qboileau.xdg.configFile."hypr/hyprland.lua".source')"
        '';
      };
    };
  };

  imports = [
    # inputs.hyprland.nixosModules.default
    ./hyprlang/settings.nix
    ./hyprlang/binds.nix
    ./lua/settings.nix
    ./lua/binds.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./waybar.nix
    # ./ironbar.nix
    # ./flameshot.nix
    ./satty.nix
    ./../dunst.nix
    #./rules.nix
    #./settings.nix
    #./smartgaps.nix
  ];

  

  config = {
    home.packages = with pkgs; [
      hyprland-qt-support
      # inputs.hyprqt6engine.packages.${pkgs.stdenv.hostPlatform.system}.hyprqt6engine
      kdePackages.qt6ct
      rose-pine-hyprcursor
    ]
    # i3-like focus/move for the dwindle binds. Only the hyprlang binds shell out to it; the
    # lua ones use ./lua/i3move.lua in-process, since a lua config rejects the legacy
    # `dispatch movefocus l` strings this binary sends. Retire it along with hyprlang.
    ++ lib.optional (config.hyprland.configType == "hyprlang") pkgs.local.hypr-i3-move;

    programs.kitty.enable = true; # required for the default Hyprland config
    services.hyprpolkitagent.enable = true;

    # NOTE: Do NOT start ksecretd as a systemd user service here.
    #
    # pam_kwallet5.so (wired up via security.pam.services.sddm.kwallet in
    # nixos/shared/security.nix) already launches `ksecretd --pam-login` during
    # the SDDM login PAM session, handing it your login password so it unlocks
    # "kdewallet" before the graphical session even starts. In KDE 6 that single
    # ksecretd provides BOTH the native KWallet API (org.kde.kwalletd6) and the
    # org.freedesktop.secrets SecretService API used by Brave, GTK apps and the
    # Proton VPN tray.
    #
    # A second, systemd-launched ksecretd starts WITHOUT the pam socket, wins the
    # org.freedesktop.secrets D-Bus name race, and leaves the wallet locked — so
    # every SecretService client (e.g. Proton VPN on startup) prompts for the
    # wallet password a second time after the SDDM login. GNOME Keyring is already
    # disabled (services.gnome.gnome-keyring.enable = false), so nothing else
    # competes for the name and no manual service is needed.

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      xwayland.enable = true;

      # Settings/binds for the selected format come from ./hyprlang or ./lua.
      configType = config.hyprland.configType;
      # Using pkgs.unstable.hyprland (fully cached, hy3 always in sync via hyprlandPlugins.hy3).
      # To switch back to flake pin, replace the two lines below with:
      #   package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      #   portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      # Active: Hyprland 0.55.4 from unstable. To fall back to 0.54.3, swap the three
      # pkgs.unstable.* lines below for the hyprland054.* variants noted in each comment.
      package = pkgs.unstable.hyprland; # FALLBACK: hyprland054.hyprland (0.54.3)
      portalPackage = pkgs.unstable.xdg-desktop-portal-hyprland; # FALLBACK: hyprland054.xdg-desktop-portal-hyprland
      plugins = [
        # hy3 plugin — built against pkgs.unstable.hyprland, always in sync.
        pkgs.unstable.hyprlandPlugins.hy3 # FALLBACK: hyprland054.hyprlandPlugins.hy3
        #
        # Flake pin alternative (use if unstable hy3 lags behind unstable hyprland):
        # inputs.hy3.packages.${pkgs.stdenv.hostPlatform.system}.hy3
      ];
    };

  };
}
