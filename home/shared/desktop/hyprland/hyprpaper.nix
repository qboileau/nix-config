{config, pkgs, inputs, ...} :
{

  services.hyprpaper.enable = true;
  services.hyprpaper.settings = {
    preload =[ 
      "${config.home.homeDirectory}/Dropbox/wallpapers/1x1/1550593747663.png" 
      "${config.home.homeDirectory}/Dropbox/wallpapers/3x1/4205197.jpg"
    ];
    wallpaper = [
      "eDP-1,${config.home.homeDirectory}/Dropbox/wallpapers/1x1/1550593747663.png"
      "desc:Philips Consumer Electronics Company 49M2C8900 AU42415000050,${config.home.homeDirectory}/Dropbox/wallpapers/3x1/4205197.jpg"
    ];
  };
}