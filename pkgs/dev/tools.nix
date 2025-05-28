    {pkgs, ...} :
{

  home.packages = with pkgs; [ 
    jq
    yq-go
    dig
    httpie
    curl
    wget
    galculator
    gh
    awscli2
    teleport_15
    unstable.terraform
    terragrunt
    harbor-cli
    dive
    golangci-lint
    killall
    graphviz
    postman
    apacheHttpd
    xournalpp
    postgresql
  ];

  xdg.desktopEntries.calculator = {
    name = "Calculator";
    exec = "galculator";
    terminal = false;
    type = "Application";
    categories = ["System"];
  };
}