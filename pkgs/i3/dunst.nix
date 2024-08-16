{pkgs, ...} :
{

  home.file.dunst {
    enable = true;
    source = "./cfg/dunstrc";
    target = "./config/dunst/dunstrc";
  }
}