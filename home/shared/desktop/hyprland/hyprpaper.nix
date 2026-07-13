{config, pkgs, inputs, ...} :
{

  services.hyprpaper.enable = true;
  # hyprpaper 0.8.x dropped the old flat `preload=`/`wallpaper=monitor,path`
  # format. Wallpapers must now be declared as `wallpaper { }` blocks. Monitor
  # description matching still works, via `monitor = desc:...` inside the block.
  services.hyprpaper.settings = {
    wallpaper = [
      {
        monitor = "eDP-1";
        path = "${config.home.homeDirectory}/Dropbox/wallpapers/1x1/1550593747663.png";
      }
      {
        monitor = "desc:Philips Consumer Electronics Company 49M2C8900 AU42415000050";
        path = "${config.home.homeDirectory}/Dropbox/wallpapers/3x1/4205197.jpg";
      }
    ];
  };
}
