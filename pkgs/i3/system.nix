# i3 setup to be imported in nixOS configuration.nix 
{pkgs, ...} :
{

  environment.pathsToLink = [ "/libexec" ];
  
  services.displayManager.defaultSession = "none+i3";

  services.xserver = {
    enable = true;

    desktopManager = {
      xterm.enable = false;
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
        
        # program for custom scripts
        scrot
        imagemagick
        bc
        feh

        arandr
        xdotool
        dunst
        libnotify
        pcmanfm
     ];
    };
  };
  
}