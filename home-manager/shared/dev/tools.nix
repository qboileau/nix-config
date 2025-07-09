    {pkgs, ...} :
{

  home.packages = with pkgs; [ 
    jq
    yq-go
    socat
    dig
    httpie
    curl
    wget
    galculator
    gh
    awscli2
    google-cloud-sdk
    teleport_16
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
    ddcui
  ];

  xdg.desktopEntries.calculator = {
    name = "Calculator";
    exec = "galculator";
    terminal = false;
    type = "Application";
    categories = ["System"];
  };
}