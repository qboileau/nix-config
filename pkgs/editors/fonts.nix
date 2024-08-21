{pkgs, ...} :
{

  home.packages = with pkgs; [ 
    fira-code
    noto-fonts
    noto-fonts-color-emoji
    font-awesome
  ];
  
  fonts.fontconfig.enable = true;
  fonts.fontconfig.defaultFonts.emoji = [
    "Noto Color Emoji"
  ];
}