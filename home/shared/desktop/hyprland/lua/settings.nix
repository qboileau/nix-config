# Hyprland settings in the lua format (-> ~/.config/hypr/hyprland.lua), the only format
# Hyprland supports from 0.57 on. Port of ../hyprlang/settings.nix; switch with
# `hyprland.configType`.
#
# How home-manager renders this: every top-level attribute becomes an `hl.<name>(...)` call,
# and a list generates one call per element. So the attribute names below are Hyprland's lua
# API functions (hl.monitor, hl.config, hl.animation, hl.env, hl.window_rule, hl.on) — an
# attribute that is not a real hl function is a lua error that aborts the WHOLE config, so
# always run `Hyprland --verify-config -c <generated file>` before switching sessions.
{config, lib, ...} :
let
  inherit (lib.generators) mkLuaInline;
  toLua = lib.generators.toLua {};

  autostart = [
    "nm-applet"
    "blueman-applet"
    "systemctl --user start hyprpolkitagent"
    "dropbox start"
    "synology-drive"
    #https://gist.github.com/brunoanc/2dea6ddf6974ba4e5d26c3139ffb7580#editing-the-configuration-file
    "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    # https://wiki.hypr.land/Hypr-Ecosystem/xdg-desktop-portal-hyprland/#share-picker-doesnt-use-the-system-theme
    "dbus-update-activation-environment --systemd --all"
    "systemctl --user import-environment QT_QPA_PLATFORMTHEME"
  ] ++ config.hyprland.autostart;

  # hyprlang's `exec-once` has no lua counterpart; autostart hangs off the start event.
  #
  # ORDERING: home-manager appends its own hyprland.start hook (dbus activation +
  # hyprland-session.target + `hyprctl plugin load`) AFTER this one, whereas in hyprlang it
  # emitted that as the FIRST exec-once. Harmless here only because the list below runs its
  # own dbus-update-activation-environment; keep those lines if you reshuffle autostart.
  startHook = ''
    function()
    ${lib.concatMapStrings (cmd: "  hl.exec_cmd(${toLua cmd})\n") autostart}end'';

  env = {
    #https://wiki.hypr.land/Configuring/Environment-variables/#xdg-specifications
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_MENU_PREFIX = "plasma-"; # fix xdg file associations for Dolphin

    #https://wiki.hypr.land/Configuring/Environment-variables/#qt-variables
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_QPA_PLATFORMTHEME = "qt6ct"; # or "hyprqt6engine"
    QT_QUICK_CONTROLS_STYLE = "org.hyprland.style";
    QT_SCALE_FACTOR = "1";

    #https://wiki.hypr.land/Configuring/Environment-variables/#toolkit-backend-variables
    GDK_BACKEND = "wayland,x11,*";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";

    XCURSOR_SIZE = "25";
    HYPRCURSOR_SIZE = "25";
    HYPRCURSOR_THEME = "rose-pine-hyprcursor";
    MOZ_ENABLE_WAYLAND = "1";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    GDK_DPI_SCALE = "1";
    GDK_SCALE = "1";
    NIXOS_OZONE_WL = "1"; # tell Electron/Chromium to run on Wayland
    ELECTRON_OZONE_PLATFORM_HINT = "auto"; # https://www.electronjs.org/docs/latest/api/environment-variables
  };
in
lib.mkIf (config.hyprland.configType == "lua") {
  wayland.windowManager.hyprland.settings = {
    # See https://wiki.hypr.land/Configuring/Basics/Monitors/
    # Same field names as hyprlang's monitorv2, one hl.monitor() call per entry.
    monitor = [
      {
        output = "eDP-1";
        mode = "2256x1504";
        position = "0x0";
        scale = 1;
        bitdepth = 10;
      }
      {
        output = "desc:Philips Consumer Electronics Company 49M2C8900 AU42415000050";
        mode = "5120x1440@240.49Hz";
        position = "auto-right";
        scale = 1;
        bitdepth = 10;
        # HDR DISABLED (2026-07-16): the Hyprland 0.55 HDR render path corrupts the display
        # (waybar/window black-flicker) AND screencopy/screenshots on RX 9070 XT (gfx1201) —
        # Hyprland #14845. Wide-gamut color management WITHOUT HDR bypasses the buggy tonemap /
        # SDR-modifier path while keeping colors correct. Re-enable by restoring cm="hdr" and
        # uncommenting the supports_hdr / luminance / sdr* lines once #14845 is fixed (or on the
        # 0.54.3 fallback).
        #cm = "wide"; # was "hdr"
        #supports_wide_color = 1;
        # --- HDR-only options, disabled together with HDR ---
        cm = "hdr";
        supports_hdr = 1;
        sdr_min_luminance = 0.05;
        min_luminance = 0.05;
        sdr_max_luminance = 200;
        max_luminance = 400;
        sdrbrightness = 1.0;
        sdrsaturation = 1.0;
        vrr = 3;
      }
      {
        output = "desc:Iiyama North America PL2440HS 1179410502548";
        mode = "1920x1080";
        position = "auto-up";
        scale = 1;
        bitdepth = 10;
      }
    ];

    # Everything hyprlang set as a top-level section lives under one hl.config() call.
    # https://wiki.hypr.land/Configuring/Basics/Variables/
    config = {
      xwayland.force_zero_scaling = true;

      render = {
        direct_scanout = 0; # disabled: =2 (auto) caused waybar + focused-window (e.g. VS Code) to flicker/go black on damage under Hyprland 0.55 on RDNA4 (RX 9070). Scanout is only a fullscreen-game latency optimization; off is safe.
        cm_enabled = true; # keep color management on so wide-gamut Philips colors are mapped correctly (off => oversaturated)
        cm_auto_hdr = 0; # DEBUG (RX 9070 / Hyprland 0.55 flicker): auto-promoting SDR content to HDR toggles the color pipeline on damage, flashing waybar + focused window black together. Was 1.
        cm_sdr_eotf = "srgb"; # Treat unspecified as sRGB. hyprlang took the int 3; lua wants the string.
      };

      general = {
        layout = config.hyprland.layout;
        gaps_in = 1;
        gaps_out = 1;
        border_size = 1;
        # hyprlang's dotted "col.active_border" keys are a nested table here.
        col = {
          inactive_border = "0xff444444";
          active_border = "0xffffffff";
          nogroup_border = "0xff444444";
          nogroup_border_active = "0xffffffff";
        };
      };

      group = {
        insert_after_current = false; # insert at last in group
        drag_into_group = 2; # drag to groupbar add to group
        merge_groups_on_groupbar = false; # groups don't merge into each other
        col = {
          border_inactive = "0xff444444";
          border_active = "0xffffffff";
          border_locked_inactive = "0xff444444";
          border_locked_active = "0xffffffff";
        };
        groupbar = {
          font_size = 12;
          font_weight_active = "bold";
          col = {
            active = "0x6600BCD1";
            inactive = "0x66006A75";
            locked_active = "0x6600BCD1";
            locked_inactive = "0x66006A75";
          };
        };
      };

      dwindle = {
        force_split = 2; # always split to the right/bottom (i3-like)
        preserve_split = true; # keep split direction when windows are removed
        smart_resizing = true; # prevent automatic resize adjustments
      };

      # hy3's own options.
      #
      # These are only known to Hyprland once hy3 has registered them, and the plugin is loaded
      # from the hyprland.start hook — i.e. after this file is first parsed. That works at
      # runtime because loading a plugin schedules a full config reload
      # (Hyprland src/plugins/PluginSystem.cpp:135), which re-applies everything below.
      #
      # It does mean `--verify-config` cannot see them and reports
      #   unknown config key 'plugin.hy3.<key>'
      # with exit 1 whenever layout = "hy3". Those specific lines are expected; anything else in
      # a verify run is a real error. To pre-flight the rest of the config, verify with
      # layout = "dwindle".
      #
      # Every key was checked against a running hy3 via `hyprctl getoption plugin:hy3:<key>`.
      # Note it is tabs:colors:*, NOT the tabs:col.* spelling the native groupbar uses — a wrong
      # key here is dropped silently.
      #
      # Emitted only when hy3 is selected (see the end of this attrset): on dwindle the plugin
      # is never loaded, so these keys would never resolve and would break --verify-config for
      # no reason.

      binds = {
        workspace_back_and_forth = true;
        scroll_event_delay = 100; # default is 300
      };

      animations.enabled = true;

      # https://wiki.hypr.land/Configuring/Basics/Variables/#input
      input = {
        kb_layout = "us";
        kb_variant = "alt-intl";
        kb_model = "pc104";
        kb_options = "terminate:ctrl_alt_bksp";
        # kb_rules = "";

        follow_mouse = 1;

        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

        touchpad = {
          natural_scroll = false;
        };
      };
    }
    // lib.optionalAttrs (config.hyprland.layout == "hy3") {
      plugin.hy3 = {
        # Match the native groupbar colours configured above, so tabs look the same.
        tabs = {
          height = 22;
          padding = 2;
          radius = 1;
          border_width = 1;
          text_height = 12;
          text_font = "Noto Sans";
          colors = {
            active = "rgba(51, 204, 255, 0.17)";
            focused = "rgba(96, 96, 96, 0.25)";
            inactive = "rgba(48, 48, 48, 0.125)";
            urgent = "rgba(255, 34, 51, 0.25)";
            locked = "rgba(144, 144, 51, 0.25)";
          };
          opacity = 0.95;
        };
        # i3 splits along the longer axis by default; hy3 does not unless told to.
        autotile.enable = true;
      };
    };

    # hyprlang "<leaf>, <enabled>, <speed>, <curve>[, <style>]" as a table.
    animation = [
      { leaf = "border";     enabled = true; speed = 2; bezier = "default"; }
      { leaf = "fade";       enabled = true; speed = 4; bezier = "default"; }
      { leaf = "windows";    enabled = true; speed = 3; bezier = "default"; style = "popin 80%"; }
      { leaf = "workspaces"; enabled = true; speed = 2; bezier = "default"; style = "slide"; }
    ];

    # hl.env(NAME, VALUE) — _args turns an attribute into a multi-argument call.
    env = lib.mapAttrsToList (name: value: { _args = [ name value ]; }) env;

    # https://wiki.hypr.land/Configuring/Basics/Window-Rules/
    # Unlike hyprlang, one rule carries many effects, so same-match rules collapse.
    window_rule = [
      #https://wiki.hyprland.org/FAQ/#how-do-i-screenshot
      #https://ryanwise.me/blog/flameshot-on-hyprland/
      {
        match = { class = "(flameshot)"; title = "(flameshot)"; };
        move = "0 0";
        pin = true;
        fullscreen_state = "3 3";
        float = true;
      }

      # Screen sharing Xwayland
      {
        match = { class = "^(xwaylandvideobridge)$"; };
        opacity = "0.0 override";
        no_anim = true;
        no_initial_focus = true;
        max_size = "1 1";
        no_blur = true;
        no_focus = true;
      }

      { match = { class = "galculator"; }; float = true; size = "341 378"; }
      { match = { class = "vlc"; }; float = true; }
      { match = { class = "mpv"; }; float = true; }
      { match = { class = "Bitwarden"; }; float = true; }
      { match = { class = "org.kde.kwalletmanager"; }; float = true; }
      # satty, the screenshot annotator the Print bind pipes grim into
      { match = { class = "com.gabm.satty"; }; float = true; }
      { match = { class = "brave"; title = "(.*)(wants to open)"; }; float = true; }
      { match = { class = "brave"; title = "(.*)(wants to save)"; }; float = true; }
      # Firefox videos windows
      { match = { class = "firefox"; title = "(Incrustation)(.*)"; }; float = true; }

      # FIXME broken since forever, ported verbatim: nix eats the backslash so the title
      # regex is really "^wind+$", and hyprland's RE2 rejects the "(?!" lookahead outright
      # ("invalid perl operator"). Fix separately so hyprlang/lua stay behaviour-identical.
      {
        match = { class = "^jetbrains-(?!toolbox)"; float = true; title = "^win\d+$"; };
        no_focus = true;
      }

      { match = { class = "^(steam)$"; }; workspace = "2"; }
      { match = { class = "^(discord)$"; }; workspace = "4"; }
    ];

    on = { _args = [ "hyprland.start" (mkLuaInline startHook) ]; };
  };
}
