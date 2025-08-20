{config, pkgs, inputs, ...} :
{

  services.hypridle.enable = true;
  home.file.hypridle = {
    enable = true;
    source = ./cfg/hypridle.conf;
    target = ".config/hypr/hypridle.conf";
  };
}