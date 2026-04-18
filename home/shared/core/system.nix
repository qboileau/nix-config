{pkgs, ...} :
{
  # Core system utilities - always installed
  # These are essential system utilities used across all hosts
  
  home.packages = with pkgs; [ 
    killall
    font-manager
  ];
}
