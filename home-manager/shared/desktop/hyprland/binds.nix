{pkgs, ...} :
{
  
   home.packages = with pkgs; [ 
    hypr-i3-move
  ];

  wayland.windowManager.hyprland.settings = {
    bind = let 
      grim = "${pkgs.grim}/bin/grim";
      slurp = "${pkgs.slurp}/bin/slurp";
    in [
      # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
      "$mod, Return, exec, $terminal"
      "$mod Shift, Q, killactive,"
      "$mod, F, fullscreen,"
      "$mod, M, exit,"
      "$mod, E, exec, $fileManager"
      "$mod, V, togglefloating,"
      "$mod, D, exec, $menu"
      "$mod, P, pseudo, # dwindle"
      "$mod, J, togglesplit," # dwindle
      "$mod, L, exec, $lock"

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

      # Move workspace to monitor
      "CTRL $mod SHIFT, right, movecurrentworkspacetomonitor, r"
      "CTRL $mod SHIFT, left, movecurrentworkspacetomonitor, l"

      # Example special workspace (scratchpad)
      "$mod, minus, togglespecialworkspace, magic"
      "$mod SHIFT, minus, movetoworkspace, special:magic"

      # Scroll through existing workspaces with mod + scroll
      "$mod, mouse_down, workspace, e+1"
      "$mod, mouse_up, workspace, e-1"

      "$mod, G, togglegroup,"

      # TODO fix conflict with movefocus
      #"$mod, left, changegroupactive, b"
      #"$mod, right, changegroupactive, f"

      # TODO fix conflict with movewindoworgroup
      #"$mod SHIFT, left, movegroupwindow, b"
      #"$mod SHIFT, right, movegroupwindow, f"
      

      #", Print, exec, XDG_CURRENT_DESKTOP=sway flameshot gui" # use when fixed
      ''
       , Print, exec, ${grim} -g "$(${slurp})" - | wl-copy -t image/png
      ''
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

    binds = [
    ];
    bindm = [
      # Move/resize windows with mod + LMB/RMB and dragging
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
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
