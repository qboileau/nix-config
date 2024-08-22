# i3 setup to be imported in home-manager
{pkgs, ...} :
{


  imports = [
    ./picom.nix
    ./i3-status-rs.nix
    ./dunst.nix
  ];

  xsession.enable = true;
  xsession.windowManager.i3 = {
    enable = true;
  };


  home.file.i3 = {
    enable = true;
    source = "./cfg/i3";
    target = ".i3/config";
    onChange = "restart";
  };

  # TODO make package derivation with pkgs.writeShellScriptBin
  home.file.lock-blur = {
    enable = true;
    source = "./cfg/scripts/lock-blur.sh";
    target = ".i3/scripts/lock-blur.sh";
  };

  home.file.monitor-switcher = {
    enable = true;
    source = "./cfg/scripts/monitor-switcher.py";
    target = ".i3/scripts/monitor-switcher.py";
  };

  home.file.power-profiles = {
    enable = true;
    source = "./cfg/scripts/power-profiles";
    target = ".i3/scripts/power-profiles";
  };


  home.file.powermenu = {
    enable = true;
    source = "./cfg/scripts/powermenu";
    target = ".i3/scripts/powermenu";
  };

  home.file.smart-wallpaper = {
    enable = true;
    source = "./cfg/scripts/smart-wallpaper.sh";
    target = ".i3/scripts/smart-wallpaper.sh";
  };

    home.file.wallpaper = {
    enable = true;
    source = "./cfg/scripts/wallpaper.sh";
    target = ".i3/scripts/wallpaper.sh";
  };


}