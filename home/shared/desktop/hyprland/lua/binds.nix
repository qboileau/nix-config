# Keybinds in the lua format. Port of ../hyprlang/binds.nix; switch with `hyprland.configType`.
#
# Key syntax differs from hyprlang: "MOD, KEY, dispatcher, args" becomes
# hl.bind("MOD + KEY", hl.dsp.<dispatcher>(<args>)) — mods joined with "+" and listed first.
# The bind* variants are options instead of separate keys: bindm -> {mouse}, bindl -> {locked},
# bindel -> {locked, repeating}.
{config, pkgs, lib, ...} :
let
  inherit (lib.generators) mkLuaInline;
  toLua = lib.generators.toLua {};

  mod = "SUPER";
  terminal = config.terminal.default;
  fileManager = "${pkgs.kdePackages.dolphin}/bin/dolphin";
  grim = "${pkgs.grim}/bin/grim";
  slurp = "${pkgs.slurp}/bin/slurp";
  satty = "${pkgs.satty}/bin/satty";
  lock = "hyprlock";
  menu = "wofi --show drun";
  screenshot = "${grim} -g \"$(${slurp})\" -t png - | ${satty} --filename -";

  # hl.bind(keys, dispatcher[, opts]); _args renders the multi-argument call.
  bind = keys: dsp: { _args = [ keys (mkLuaInline dsp) ]; };
  bindWith = opts: keys: dsp: { _args = [ keys (mkLuaInline dsp) opts ]; };

  exec = cmd: "hl.dsp.exec_cmd(${toLua cmd})";

  # hy3's lua functions live under hl.plugin.hy3, which only exists once the plugin has been
  # loaded — and home-manager loads plugins from the hyprland.start hook, i.e. AFTER this file
  # is evaluated. Referencing hl.plugin.hy3.* at the top level would therefore index nil, so
  # wrap each one in a function: hl.bind also accepts a callback, resolved at keypress time.
  hy3 = call: "function() hl.dispatch(hl.plugin.hy3.${call}) end";

  base-bind = [
    (bind "${mod} + Return" (exec terminal))
    (bind "${mod} + SHIFT + Q" "hl.dsp.window.close()")
    (bind "${mod} + SHIFT + R" (exec "hyprctl reload"))
    (bind "${mod} + F" "hl.dsp.window.fullscreen()")
    (bind "${mod} + M" "hl.dsp.exit()")
    (bind "${mod} + E" (exec fileManager))
    (bind "${mod} + V" ''hl.dsp.window.float({ action = "toggle" })'')
    (bind "${mod} + D" (exec menu))
    (bind "${mod} + P" "hl.dsp.window.pin()")
    # (bind "${mod} + J" ''hl.dsp.layout("togglesplit")'')
    (bind "${mod} + L" (exec lock))
    (bind "Print" (exec screenshot))
    (bind "${mod} + mouse_down" ''hl.dsp.focus({ workspace = "e+1" })'')
    (bind "${mod} + mouse_up" ''hl.dsp.focus({ workspace = "e-1" })'')

    # Example special workspace (scratchpad)
    (bind "${mod} + minus" ''hl.dsp.workspace.toggle_special("magic")'')
    (bind "${mod} + SHIFT + minus" ''hl.dsp.window.move({ workspace = "special:magic" })'')

    # Zoom
    (bind "${mod} + SHIFT + CTRL + mouse_down" (exec "hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '.float * 1.2')"))
    (bind "${mod} + SHIFT + CTRL + mouse_up" (exec "hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '(.float * 0.8) | if . < 1 then 1 else . end')"))
  ];

  #https://git.outfoxxed.me/outfoxxed/nixnew/src/branch/master/modules/hyprland/hyprland.conf
  hy3-bind = [
    (bind "${mod} + a" (hy3 ''change_focus("raise")''))
    (bind "${mod} + SHIFT + a" (hy3 ''change_focus("lower")''))
    (bind "${mod} + g" (hy3 ''make_group("tab")''))
    (bind "${mod} + tab" (hy3 "toggle_focus_layer()"))

    # Move focus with mod + arrow keys
    (bind "${mod} + left" (hy3 ''move_focus("l")''))
    (bind "${mod} + right" (hy3 ''move_focus("r")''))
    (bind "${mod} + up" (hy3 ''move_focus("u")''))
    (bind "${mod} + down" (hy3 ''move_focus("d")''))

    (bind "${mod} + CTRL + left" (hy3 ''move_focus("l", { visible = true, warp = false })''))
    (bind "${mod} + CTRL + right" (hy3 ''move_focus("r", { visible = true, warp = false })''))
    (bind "${mod} + CTRL + up" (hy3 ''move_focus("u", { visible = true, warp = false })''))
    (bind "${mod} + CTRL + down" (hy3 ''move_focus("d", { visible = true, warp = false })''))

    # Move window with mod + SHIFT + arrow keys
    (bind "${mod} + SHIFT + left" (hy3 ''move_window("l", { once = true })''))
    (bind "${mod} + SHIFT + right" (hy3 ''move_window("r", { once = true })''))
    (bind "${mod} + SHIFT + up" (hy3 ''move_window("u", { once = true })''))
    (bind "${mod} + SHIFT + down" (hy3 ''move_window("d", { once = true })''))

    (bind "${mod} + CTRL + SHIFT + left" (hy3 ''move_window("l", { once = true, visible = true })''))
    (bind "${mod} + CTRL + SHIFT + right" (hy3 ''move_window("r", { once = true, visible = true })''))
    (bind "${mod} + CTRL + SHIFT + up" (hy3 ''move_window("u", { once = true, visible = true })''))
    (bind "${mod} + CTRL + SHIFT + down" (hy3 ''move_window("d", { once = true, visible = true })''))
  ] ++ (builtins.concatLists (builtins.genList (
      x: let
        ws = let
          c = (x + 1) / 10;
        in
          builtins.toString (x + 1 - (c * 10));
      in [
        (bind "${mod} + ${ws}" "hl.dsp.focus({ workspace = ${toString (x + 1)} })")
        (bind "${mod} + SHIFT + ${ws}" (hy3 ''move_to_workspace("${toString (x + 1)}")''))
      ]
    )
    10));

  dwindle-bind = [
    # Move focus with mod + arrow keys
    (bind "${mod} + left" ''i3move.focus("l")'')
    (bind "${mod} + right" ''i3move.focus("r")'')
    (bind "${mod} + up" ''i3move.focus("u")'')
    (bind "${mod} + down" ''i3move.focus("d")'')

    # Move window with mod + SHIFT + arrow keys
    (bind "${mod} + SHIFT + left" ''i3move.move("l")'')
    (bind "${mod} + SHIFT + right" ''i3move.move("r")'')
    (bind "${mod} + SHIFT + up" ''i3move.move("u")'')
    (bind "${mod} + SHIFT + down" ''i3move.move("d")'')

    (bind "${mod} + G" "hl.dsp.group.toggle()")

    (bind "CTRL + ${mod} + SHIFT + right" ''hl.dsp.workspace.move({ monitor = "r" })'')
    (bind "CTRL + ${mod} + SHIFT + left" ''hl.dsp.workspace.move({ monitor = "l" })'')
    (bind "CTRL + ${mod} + SHIFT + up" ''hl.dsp.workspace.move({ monitor = "u" })'')
    (bind "CTRL + ${mod} + SHIFT + down" ''hl.dsp.workspace.move({ monitor = "d" })'')
  ] ++ (builtins.concatLists (builtins.genList (
      x: let
        ws = let
          c = (x + 1) / 10;
        in
          builtins.toString (x + 1 - (c * 10));
      in [
        (bind "${mod} + ${ws}" "hl.dsp.focus({ workspace = ${toString (x + 1)} })")
        (bind "${mod} + SHIFT + ${ws}" "hl.dsp.window.move({ workspace = ${toString (x + 1)} })")
      ]
    )
    10));

  final-bind = base-bind ++ dwindle-bind;
in
lib.mkIf (config.hyprland.configType == "lua") {
  # package.path already covers ~/.config/hypr/?.lua, so this is require()-able by name.
  xdg.configFile."hypr/i3move.lua".source = ./i3move.lua;

  wayland.windowManager.hyprland.settings = {
    # `_var` renders as a `local` ahead of every hl.* call, so the binds below can use it.
    i3move = { _var = mkLuaInline ''require("i3move")''; };

    bind = final-bind

      # Move/resize windows with mod + LMB/RMB and dragging
      ++ map (b: bindWith { mouse = true; } b.keys b.dsp) [
        { keys = "${mod} + mouse:272"; dsp = "hl.dsp.window.drag()"; }
        { keys = "${mod} + mouse:273"; dsp = "hl.dsp.window.resize()"; }
      ]

      # Requires playerctl
      ++ map (b: bindWith { locked = true; } b.keys b.dsp) [
        { keys = "XF86AudioNext"; dsp = exec "playerctl next"; }
        { keys = "XF86AudioPause"; dsp = exec "playerctl play-pause"; }
        { keys = "XF86AudioPlay"; dsp = exec "playerctl play-pause"; }
        { keys = "XF86AudioPrev"; dsp = exec "playerctl previous"; }
      ]

      # Laptop multimedia keys for volume and LCD brightness
      ++ map (b: bindWith { locked = true; repeating = true; } b.keys b.dsp) [
        { keys = "XF86AudioRaiseVolume"; dsp = exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"; }
        { keys = "XF86AudioLowerVolume"; dsp = exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"; }
        { keys = "XF86AudioMute"; dsp = exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
        { keys = "XF86AudioMicMute"; dsp = exec "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }
        { keys = "XF86MonBrightnessUp"; dsp = exec "brightnessctl s 10%+"; }
        { keys = "XF86MonBrightnessDown"; dsp = exec "brightnessctl s 10%-"; }
      ];
  };
}
