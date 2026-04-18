{pkgs, ...} :
{
  # Base tools - always installed, no option to disable
  # These are essential development utilities used across all hosts
  
  home.packages = with pkgs; [ 
    # Essential utilities
    killall
    jq
    yq-go
    curl
    wget
    
    # Development tools
    gh
    graphviz
    
    # Utilities
    galculator
    xournalpp
    ddcui
  ];
}
