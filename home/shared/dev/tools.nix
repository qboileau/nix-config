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
    gh
    pgcli
    awscli2
    google-cloud-sdk
    teleport_17
    unstable.terraform
    terragrunt
    terraform-docs
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
    nss # certutil
    mkcert
  ];
}