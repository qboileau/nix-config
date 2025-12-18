{pkgs, ...} :
{

  home.packages = with pkgs; [ 
    nerd-fonts.symbols-only
    nerd-fonts.fira-code
    nerd-fonts.noto
    noto-fonts
    noto-fonts-color-emoji
    font-awesome
  ];
  
  fonts.fontconfig.enable = true;
  fonts.fontconfig.defaultFonts.serif = [
    "NotoSerif Nerd Font"
  ];
  fonts.fontconfig.defaultFonts.sansSerif = [
    "NotoSans Nerd Font"
  ];
  fonts.fontconfig.defaultFonts.monospace = [
    "FiraCode Nerd Font Mono"
    "NotoMono Nerd Font Mono"
  ];
  fonts.fontconfig.defaultFonts.emoji = [
    "FiraCode Nerd Font Mono"
    "Symbols Nerd Font Mono"
    "Noto Color Emoji"
  ];
}