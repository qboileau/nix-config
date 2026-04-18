{pkgs, ...} :
{
  # Base dev tools - always installed, no option to disable
  # These are essential development utilities used across all hosts
  
  home.packages = with pkgs; [ 
    # Essential utilities
    jq
    yq-go
    
    # Development tools
    gh
  ];
}
