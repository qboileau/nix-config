{pkgs, ...} :
{

  services.picom = {
    enable = true;
    shadow = true;
    shadowOpacity = 0.75;
    shadowOffsets = [
      (-7)
      (-7)
    ];
    shadowExclude = [
      "name = 'Notification'"
      "class_g = 'Conky'"
      "class_g ?= 'Notify-osd'"
      "class_g = 'Cairo-clock'"
      "_GTK_FRAME_EXTENTS@:c"
      "_NET_WM_STATE@:32a *= '_NET_WM_STATE_HIDDEN'"
    ];
    fade =true;
    fadeSteps = [
      0.15
      0.14
    ];
    inactiveOpacity = 0.91;
    menuOpacity = 1.0;
    activeOpacity = 1.0;
    opacityRules = [
      "99:class_g = 'GIMP'"
      "99:name *?= 'Screenshot'"
      "99:class_g = 'VirtualBox'"
      "99:name *?= 'VLC'"
      "95:class_g = 'URxvt' && !_NET_WM_STATE@:32a"
      "0:_NET_WM_STATE@:32a *= '_NET_WM_STATE_HIDDEN'" # make all hidden windows completely transparent
    ];
  };

}