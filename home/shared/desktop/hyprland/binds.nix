{pkgs, ...} :
let
  terminal = "${pkgs.unstable.alacritty}/bin/alacritty";
  fileManager = "${pkgs.kdePackages.dolphin}/bin/dolphin";
  grim = "${pkgs.grim}/bin/grim";
  slurp = "${pkgs.slurp}/bin/slurp";
  wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";

  base-bind = [
    "$mod, Return, exec, ${terminal}"
    "$mod SHIFT, Q, killactive,"
    "$mod SHIFT, R, exec, hyprctl reload"
    "$mod, F, fullscreen,"
    "$mod, M, exit,"
    "$mod, E, exec, ${fileManager}"
    "$mod, V, togglefloating,"
    "$mod, D, exec, $menu"
    "$mod, P, pin, active"
    "$mod, J, togglesplit," 
    "$mod, L, exec, $lock"
    ''
      , Print, exec, ${grim} -g "$(${slurp})" - | ${wl-copy} -t image/png
    ''
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

    "$mod CTRL SHIFT, left, hy3:movewindow, l, once, visible"
    "$mod CTRL SHIFT, right, hy3:movewindow, r, once, visible"
    "$mod CTRL SHIFT, up, hy3:movewindow, u, once, visible"
    "$mod CTRL SHIFT, down, hy3:movewindow, d, once, visible"
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

    "CTRL $mod SHIFT, right, movecurrentworkspacetomonitor, r"
    "CTRL $mod SHIFT, left, movecurrentworkspacetomonitor, l"
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

  final-bind = base-bind ++ dwindle-bind;
in {
  
   home.packages = with pkgs; [ 
    hypr-i3-move
  ];

  wayland.windowManager.hyprland.settings = {
    bind = final-bind;
    # bind = [
    #   # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
    #   "$mod, Return, exec, $terminal"
    #   "$mod Shift, Q, killactive,"
    #   "$mod, F, fullscreen,"
    #   "$mod, M, exit,"
    #   "$mod, E, exec, $fileManager"
    #   "$mod, V, togglefloating,"
    #   "$mod, D, exec, $menu"
    #   "$mod, P, pseudo, # dwindle"
    #   "$mod, J, togglesplit," # dwindle
    #   "$mod, L, exec, $lock"

    #   # Move focus with mod + arrow keys
    #   "$mod, left, exec, hypr-i3-move focus l"
    #   "$mod, right, exec, hypr-i3-move focus r"
    #   "$mod, up, exec, hypr-i3-move focus u"
    #   "$mod, down, exec, hypr-i3-move focus d"
      
    #   # Move window with mod + SHIFT + arrow keys
    #   "$mod SHIFT, left, exec, hypr-i3-move move l"
    #   "$mod SHIFT, right, exec, hypr-i3-move move r"
    #   "$mod SHIFT, up, exec, hypr-i3-move move u"
    #   "$mod SHIFT, down, exec, hypr-i3-move move d"

    #   # # Move focus with mod + arrow keys
    #   # "$mod, left, hy3:movefocus, l"
    #   # "$mod, right, hy3:movefocus, r"
    #   # "$mod, up, hy3:movefocus, u"
    #   # "$mod, down, hy3:movefocus, d"
      
    #   # # Move window with mod + SHIFT + arrow keys
    #   # "$mod SHIFT, left, hy3:movewindow, l"
    #   # "$mod SHIFT, right, hy3:movewindow, r"
    #   # "$mod SHIFT, up, hy3:movewindow, u"
    #   # "$mod SHIFT, down, hy3:movewindow, d"

    #   # Move workspace to monitor
    #   "CTRL $mod SHIFT, right, movecurrentworkspacetomonitor, r"
    #   "CTRL $mod SHIFT, left, movecurrentworkspacetomonitor, l"

    #   # Example special workspace (scratchpad)
    #   "$mod, minus, togglespecialworkspace, magic"
    #   "$mod SHIFT, minus, movetoworkspace, special:magic"

    #   # Scroll through existing workspaces with mod + scroll
    #   "$mod, mouse_down, workspace, e+1"
    #   "$mod, mouse_up, workspace, e-1"

    #   "$mod, G, togglegroup,"

    #   # TODO fix conflict with movefocus
    #   #"$mod, left, changegroupactive, b"
    #   #"$mod, right, changegroupactive, f"

    #   # TODO fix conflict with movewindoworgroup
    #   #"$mod SHIFT, left, movegroupwindow, b"
    #   #"$mod SHIFT, right, movegroupwindow, f"
      

    #   # ", Print, exec, XDG_CURRENT_DESKTOP=sway flameshot gui"
    #   ''
    #    , Print, exec, ${grim} -g "$(${slurp})" - | ${wl-copy} -t image/png
    #   ''
    # ] ++ (builtins.concatLists (builtins.genList (
    #   x: let
    #     ws = let
    #       c = (x + 1) / 10;
    #     in
    #       builtins.toString (x + 1 - (c * 10));
    #   in [
    #     "$mod, ${ws}, workspace, ${toString (x + 1)}"
    #     "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
    #   ]
    # )
    # 10));

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
