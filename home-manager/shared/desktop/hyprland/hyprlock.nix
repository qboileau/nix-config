{config, pkgs, inputs, ...} :
{

  programs.hyprlock.enable = true;
  home.file.hyprlock = {
    enable = true;
    source = ./cfg/hyprlock.conf;
    target = ".config/hypr/hyprlock.conf";
  };
}