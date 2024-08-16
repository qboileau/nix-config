    {pkgs, ...} :
{

  home.packages = with pkgs; [ 
    jq
    yq
    dig
    httpie
    curl
    wget
  ];
    
}