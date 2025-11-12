{pkgs, ...} :
{

  imports = [ ];

  home.packages = with pkgs; [ 
    # work tools 
    slack
    unstable.brave
    chromium
    _1password-gui
  ];

}