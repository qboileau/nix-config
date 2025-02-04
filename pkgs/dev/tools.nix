    {pkgs, ...} :
{

  home.packages = with pkgs; [ 
    jq
    yq
    dig
    httpie
    curl
    wget
    gh
    awscli2
    teleport_15
    terraform
    harbor-cli
    dive
  ];
    
}