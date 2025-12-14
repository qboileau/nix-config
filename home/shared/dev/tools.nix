{pkgs, ...} :
let 
  gdk = pkgs.google-cloud-sdk.withExtraComponents( with pkgs.google-cloud-sdk.components; [
    gke-gcloud-auth-plugin
  ]);
in {

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
    pgcli
    awscli2
    gdk
    teleport_17
    unstable.terraform
    terragrunt
    terraform-docs
    harbor-cli
    dive
    nixfmt-rfc-style
    unstable.golangci-lint
    killall
    graphviz
    postman
    apacheHttpd
    xournalpp
    postgresql
    ddcui
    nss # certutil
    mkcert
    unstable.claude-code
  ];

  xdg.desktopEntries.calculator = {
    name = "Calculator";
    exec = "galculator";
    terminal = false;
    type = "Application";
    categories = ["System"];
  };
}