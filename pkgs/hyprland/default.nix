{pkgs, ...} :
{

  home.file.hyperland = {
    enable = true;
    source = ./cfg/hyperland.conf;
    target = ".config/hypr/hyprland.conf";
  };

}