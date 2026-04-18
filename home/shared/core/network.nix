{pkgs, ...} :
{
  # Core network utilities - always installed
  # Essential network tools needed for basic system operation
  
  home.packages = with pkgs; [ 
    curl
    wget
    dig
    httpie
  ];
}
