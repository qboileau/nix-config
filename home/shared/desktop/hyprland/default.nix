{config, pkgs, lib,inputs, ...} :
with lib;
let
  # Pre-wired FALLBACK to known-good Hyprland 0.54.3 (pre-26.05 unstable rev), for the RDNA4
  # HDR flicker + screencopy corruption bug (Hyprland #14845) on RX 9070 XT. 0.54 predates the
  # broken 0.55 HDR render path. Currently INACTIVE (package lines below use pkgs.unstable =
  # 0.55.4); activate by swapping the three package lines to their hyprland054.* variants.
  # See memory hyprland-rdna4-screencopy-stale.
  hyprland054 = inputs.nixpkgs-hyprland-054.legacyPackages.${pkgs.stdenv.hostPlatform.system};

  # Single source for Hyprland + its plugins. Taking both from ONE package set is what keeps
  # them ABI-compatible: Hyprland refuses any plugin whose reported API version differs, and
  # that string is its own git commit hash plus the minor versions of aquamarine/hyprutils/
  # hyprgraphics (src/plugins/PluginAPI.hpp), so "same 0.56.x" is not sufficient — it has to be
  # the same build. Never mix this with a flake-pinned hyprland.
  hyprPkgs = pkgs.unstable;
  hyprlandPkg = hyprPkgs.hyprland;
  hy3Pkg = hyprPkgs.hyprlandPlugins.hy3;

  # hy3 is versioned after the Hyprland it targets (upstream tags are hl<hyprland ver>.<n>, so
  # 0.56.0.1 -> Hyprland 0.56.x). nixpkgs' mkHyprlandPlugin asserts NOTHING about this, so when
  # nixpkgs bumps Hyprland before hy3 catches up you get a plugin built against headers it does
  # not support: either a failed build after a long rebuild, or a plugin that loads and misbehaves.
  hy3TargetsHyprland =
    lib.versions.majorMinor hy3Pkg.version == lib.versions.majorMinor hyprlandPkg.version;

  # Backstop for the other direction: hy3 compiled against a *different* hyprland derivation
  # than the one being installed (the case a version check cannot see).
  hy3LinkedHyprland =
    lib.findFirst (d: (d.pname or "") == "hyprland") null (hy3Pkg.buildInputs or [ ]);
  hy3LinkedSameHyprland =
    hy3LinkedHyprland != null && hy3LinkedHyprland.drvPath == hyprlandPkg.drvPath;

  usingHy3 = config.hyprland.layout == "hy3";
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
      layout = lib.mkOption {
        type = lib.types.enum [
          "dwindle"
          "hy3"
        ];
        default = "dwindle";
        description = ''
          Tiling layout. "dwindle" is Hyprland's built-in automatic split layout, driven by the
          i3-like focus/move helper (./lua/i3move.lua, or pkgs/hypr-i3-move under hyprlang).
          "hy3" is the hy3 plugin: manual i3/sway-style tiling with real tab groups.

          Selecting hy3 swaps the whole arrow-key bind set AND pulls in the plugin, which is
          only loaded at compositor start — so flipping this needs a full Hyprland restart,
          not just `hyprctl reload`.

          The plugin is only installed when this is "hy3", which is deliberate: a stale hy3 in
          nixpkgs then cannot block a system update while you are on dwindle.
        '';
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
    # Version gate for hy3. Only enforced when hy3 is actually selected, so a lagging hy3 in
    # nixpkgs cannot block `nix flake update` + rebuild while you are on dwindle.
    assertions = [
      {
        assertion = !usingHy3 || hy3TargetsHyprland;
        message = ''
          hyprland.layout = "hy3" but hy3 ${hy3Pkg.version} targets Hyprland ${lib.versions.majorMinor hy3Pkg.version}.x,
          while the configured Hyprland is ${hyprlandPkg.version}. hy3 normally lags a new Hyprland
          release by a few days, so nixpkgs has probably moved Hyprland ahead of it.

          Either wait for hy3 ${lib.versions.majorMinor hyprlandPkg.version}.x to land, pin nixpkgs-unstable back, or set
          hyprland.layout = "dwindle" to keep updating without the plugin.
        '';
      }
      {
        assertion = !usingHy3 || hy3LinkedSameHyprland;
        message = ''
          hy3 was built against a different Hyprland derivation than the one being installed.
          Hyprland compares its git commit hash when loading a plugin, so this combination will
          be refused at runtime and you would boot into a session with no working layout.

          Take hyprland and hyprlandPlugins.hy3 from the SAME package set (see hyprPkgs in
          home/shared/desktop/hyprland/default.nix); do not mix nixpkgs with a flake pin.
        '';
      }
    ];

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
      # Hyprland + plugins both come from hyprPkgs (see the let block) so they are guaranteed to
      # be the same build. To fall back to 0.54.3 for the RDNA4 bug, point hyprPkgs at
      # hyprland054 instead of editing these lines; that keeps hy3 in step automatically.
      package = hyprlandPkg;
      portalPackage = hyprPkgs.xdg-desktop-portal-hyprland;
      # Only loaded when actually selected — see the hyprland.layout option. Plugins load at
      # compositor start, so switching layout needs a Hyprland restart, not a reload.
      plugins = lib.optional usingHy3 hy3Pkg;
    };

  };
}
