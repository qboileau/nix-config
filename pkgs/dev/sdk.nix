{pkgs, ...} :
{

  home.packages = with pkgs; [ 
    jdk
    jdk17
  ];
}