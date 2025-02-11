{pkgs, ...} :
{

  services.dunst.enable=true;
  home.file.dunst = {
    enable = true;
    source = ./cfg/dunstrc;
    target = "./.config/dunst/dunstrc";
  };
}