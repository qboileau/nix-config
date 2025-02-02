{pkgs, ...} :
{

  home.file.sway = {
    enable = true;
    source = ./cfg/config;
    target = ".config/sway/config";
  };

}