# i3 setup to be imported in nixOS configuration.nix 
{pkgs, ...} :
{

  environment.pathsToLink = [ "/libexec" ];
  
  services.xserver = {
    enable = true;

    desktopManager = {
      xterm.enable = false;
    };
   
    displayManager = {
        defaultSession = "none+i3";
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        picom
        i3status-rust
        i3-rounded # i3-gaps fork
        #i3blocks
        #i3blocks-gaps
        i3lock
        xss-lock
        # xorg
        xorg.xbacklight
        xorg.setxkbmap
        #menus
        dmenu-rs
        rofi
        rofi-emoji

        arandr 
        dunst
        feh
        pcmanfm
     ];
    };
  };
  
}