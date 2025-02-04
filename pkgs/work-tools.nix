{pkgs, ...} :
{

  imports = [ ];

  home.packages = with pkgs; [ 
    # work tools 
    slack
    brave
    _1password-gui
  ];

}