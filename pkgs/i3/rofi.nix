{pkgs, ...} :
{

  home.file.arc_dark_colors = {
    enable = true;
    source = ./cfg/rofi/arc_dark_colors.rasi ;
    target = ".config/rofi/arc_dark_colors.rasi";
  };

  home.file.arc_dark_transparent_colors = {
    enable = true;
    source = ./cfg/rofi/arc_dark_transparent_colors.rasi ;
    target = ".config/rofi/arc_dark_transparent_colors.rasi";
  };

  home.file.monitor-switcher = {
    enable = true;
    source = ./cfg/rofi/monitor-switcher.rasi ;
    target = ".config/rofi/monitor-switcher.rasi";
  };
  
  home.file.power-profiles = {
    enable = true;
    source = ./cfg/rofi/power-profiles.rasi ;
    target = ".config/rofi/power-profiles.rasi";
  };

  home.file.powermenu = {
    enable = true;
    source = ./cfg/rofi/powermenu.rasi ;
    target = ".config/rofi/powermenu.rasi";
  };

  home.file.rofidmenu = {
    enable = true;
    source = ./cfg/rofi/rofidmenu.rasi ;
    target = ".config/rofi/rofidmenu.rasi";
  };

  home.file.rofikeyhint = {
    enable = true;
    source = ./cfg/rofi/rofikeyhint.rais ;
    target = ".config/rofi/rofikeyhint.rasi";
  };

}