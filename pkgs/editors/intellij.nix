{pkgs, ...} :
{

  home.packages = with pkgs; [ 
    jetbrains.jdk
    jetbrains.idea-ultimate
  ];
}