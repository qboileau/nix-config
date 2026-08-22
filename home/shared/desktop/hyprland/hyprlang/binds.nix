# Keybinds in the legacy hyprlang format. See ../lua/binds.nix for the lua equivalent;
# switch with `hyprland.configType`.
{config, pkgs, lib, ...} :
let
  terminal = config.terminal.default;
  fileManager = "${pkgs.kdePackages.dolphin}/bin/dolphin";
  grim = "${pkgs.grim}/bin/grim";
  slurp = "${pkgs.slurp}/bin/slurp";
  satty = "${pkgs.satty}/bin/satty";
  wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy"; # ${wl-copy} -t image/png
  lock = "hyprlock";
  menu = "wofi --show drun";
  screenshot = "${grim} -g \"$(${slurp})\" -t png - | ${satty} --filename -";

  usingHy3 = config.hyprland.layout == "hy3";

  # hy3 nodes are not plain windows: killactive on a focused tab group only takes the visible
  # window, hy3:killactive acts on the node.
  kill = if usingHy3 then "hy3:killactive," else "killactive,";

  # Layout-agnostic, so both bind sets need them — they used to live only in dwindle-bind.
  workspace-to-monitor-bind = [
    "CTRL $mod SHIFT, right, movecurrentworkspacetomonitor, r"
    "CTRL $mod SHIFT, left, movecurrentworkspacetomonitor, l"
    "CTRL $mod SHIFT, up, movecurrentworkspacetomonitor, u"
    "CTRL $mod SHIFT, down, movecurrentworkspacetomonitor, d"
  ];

  base-bind = [
    "$mod, Return, exec, ${terminal}"
    "$mod SHIFT, Q, ${kill}"
    "$mod SHIFT, R, exec, hyprctl reload"
    "$mod, F, fullscreen,"
    "$mod, M, exit,"
    "$mod, E, exec, ${fileManager}"
    "$mod, V, togglefloating,"
    "$mod, D, exec, ${menu}"
    "$mod, P, pin, active"
    # "$mod, J, togglesplit," 
    "$mod, L, exec, ${lock}"
    ", Print, exec, ${screenshot}"    
    "$mod, mouse_down, workspace, e+1"
    "$mod, mouse_up, workspace, e-1"
    
    # Example special workspace (scratchpad)
    "$mod, minus, togglespecialworkspace, magic"
    "$mod SHIFT, minus, movetoworkspace, special:magic"

    # Zoom 
    "$mod SHIFT CTRL, mouse_down, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '.float * 1.2')"
    "$mod SHIFT CTRL, mouse_up, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '(.float * 0.8) | if . < 1 then 1 else . end')"

  ];

  #https://git.outfoxxed.me/outfoxxed/nixnew/src/branch/master/modules/hyprland/hyprland.conf
  hy3-bind = [
    "$mod, a, hy3:changefocus, raise"
    "$mod SHIFT, a, hy3:changefocus, lower"
    "$mod, g, hy3:makegroup, tab"
    "$mod, tab, hy3:togglefocuslayer"

    # i3 split-orientation reflexes. i3 uses mod+h / mod+v / mod+e, but mod+V is togglefloating
    # and mod+E is the file manager here, so only mod+h keeps its i3 key.
    "$mod SHIFT, h, hy3:makegroup, h"
    "$mod SHIFT, v, hy3:makegroup, v"
    "$mod SHIFT, e, hy3:changegroup, opposite"
    "$mod SHIFT, g, hy3:changegroup, untab"
    "$mod SHIFT, f, hy3:expand, maximize"

    # Move focus with mod + arrow keys
    "$mod, left, hy3:movefocus, l"
    "$mod, right, hy3:movefocus, r"
    "$mod, up, hy3:movefocus, u"
    "$mod, down, hy3:movefocus, d"

    "$mod CTRL, left, hy3:movefocus, l, visible, nowarp"
    "$mod CTRL, right, hy3:movefocus, r, visible, nowarp"
    "$mod CTRL, up, hy3:movefocus, u, visible, nowarp"
    "$mod CTRL, down, hy3:movefocus, d, visible, nowarp"
    
    # Move window with mod + SHIFT + arrow keys
    "$mod SHIFT, left, hy3:movewindow, l, once"
    "$mod SHIFT, right, hy3:movewindow, r, once"
    "$mod SHIFT, up, hy3:movewindow, u, once"
    "$mod SHIFT, down, hy3:movewindow, d, once"

    # NOTE the upstream hy3 reference config also binds $mod CTRL SHIFT + arrows to
    # hy3:movewindow ... visible. Dropped deliberately: they collide with
    # workspace-to-monitor-bind above (same mods+key), and only one survives.
  ] ++ (builtins.concatLists (builtins.genList (
      x: let
        ws = let
          c = (x + 1) / 10;
        in
          builtins.toString (x + 1 - (c * 10));
      in [
        "$mod, ${ws}, workspace, ${toString (x + 1)}"
        "$mod SHIFT, ${ws}, hy3:movetoworkspace, ${toString (x + 1)}"
      ]
    )
    10)); 

  dwindle-bind = [
    # Move focus with mod + arrow keys
    "$mod, left, exec, hypr-i3-move focus l"
    "$mod, right, exec, hypr-i3-move focus r"
    "$mod, up, exec, hypr-i3-move focus u"
    "$mod, down, exec, hypr-i3-move focus d"
    
    # Move window with mod + SHIFT + arrow keys
    "$mod SHIFT, left, exec, hypr-i3-move move l"
    "$mod SHIFT, right, exec, hypr-i3-move move r"
    "$mod SHIFT, up, exec, hypr-i3-move move u"
    "$mod SHIFT, down, exec, hypr-i3-move move d"

    "$mod, G, togglegroup,"
  ] ++ (builtins.concatLists (builtins.genList (
      x: let
        ws = let
          c = (x + 1) / 10;
        in
          builtins.toString (x + 1 - (c * 10));
      in [
        "$mod, ${ws}, workspace, ${toString (x + 1)}"
        "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
      ]
    )
    10));

  final-bind =
    base-bind ++ workspace-to-monitor-bind ++ (if usingHy3 then hy3-bind else dwindle-bind);
in
lib.mkIf (config.hyprland.configType == "hyprlang") {
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    bind = final-bind;
    
    bindm = [
      # Move/resize windows with mod + LMB/RMB and dragging
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
      # "$mod, mouse:277, movetoworkspace" # not working because no movetoworkspace on mouse binds
    ];
    bindl = [
      # Requires playerctl
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPause, exec, playerctl play-pause"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPrev, exec, playerctl previous"
    ];
    bindel = [
      # Laptop multimedia keys for volume and LCD brightness
      ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
      ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
      ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
    ];
  };
}
