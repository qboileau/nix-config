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
    terragrunt
    harbor-cli
    dive
    golangci-lint
    killall
    graphviz
    postman
  ];
    
}