{pkgs, ...} :
{

  imports = [
    ./git.nix
  ];

  home.packages = with pkgs; [ 
    alacritty
    starship
    # replacement tools
    bat # better cat
    eza # better ls
    ripgrep-all # better grep
    fd # better find
    duf # better du / df
    tealdeer # TLDR
    fzf
    font-manager

    # system monitoring 
    htop
    glances
    bottom

    # dev tools
    jq
    yq
    dig
    httpie
    curl
    wget
  ];

  home.shellAliases = {
    ls = "eza --group-directories-first --time-style=long-iso --git --color=auto -F --octal-permissions";
    ll = "eza -lah --group-directories-first --time-style=long-iso --git --color=auto -F --octal-permissions";
    tree = "eza -lah --group-directories-first --time-style=long-iso --git --color=auto --tree -F";
    grep = "rg";
    cp = "cp -i"; # confirm before overwriting somethin
    df = "duf";
    free = "free -m";                      
    ip = "ip --color";
    ipb = "ip --color --brief";
    cat = "bat";
    git = "LANG="en_US.UTF-8" git";
    ssh = "TERM=xterm-color ssh";
    source_bash = "source ~/.bashrc";
    updateBash = "source ~/.bashrc";
    updateXresources = "xrdb ~/.Xresources";
    mvncis = "mvn clean install -DskipTests --show-version";
    mvnc = "mvn clean --show-version";
    mvni = "mvn install --show-version";
    mvnis = "mvn install -DskipTests --show-version";
    mvnci = "mvn clean install --show-version";
    mvnt = "mvn test --show-version";
  };

  home.sessionVariables = {
    TERMINAL = "alacritty";
    TERM = "alacritty";
  }

}