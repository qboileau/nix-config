{pkgs, ...} :
{

  imports = [ ];

  home.packages = with pkgs; [ 
    # work tools 
    slack
    brave
  ];

}