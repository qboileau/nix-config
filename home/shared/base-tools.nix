{pkgs, inputs, ...} :
{

  imports = [
    ./git.nix
  ];

  home.packages = with pkgs; [
    fastfetch
    # replacement tools
    duf # better du / df
    font-manager

    # system monitoring 
    glances
    bottom
    htop

    # dev tools
    dig
    httpie
    curl
    wget

    #proton 
    proton-pass
    protonvpn-gui
    unstable.proton-authenticator

    # others
    filezilla
    unstable.discord-ptb
    bitwarden-desktop
    unstable.spotify
    inputs.qbz.packages.${pkgs.system}.default
    cameractrls-gtk4

    synology-drive-client
    unstable.tail-tray

    overskride # bluetooth GUI
    solaar # logitech devices GUI

    galculator
  ];

  programs.firefox.enable = true;

  # replacement tools
  programs.bat.enable=true; # better cat
  programs.eza.enable=true; # better ls
  programs.ripgrep.enable=true;# better grep
  programs.fd.enable=true; # better find
  programs.tealdeer.enable=true;  # TLDR
  programs.fzf.enable=true;  # TLDR

  services.dropbox.enable=true;

  # system monitoring 
  programs.htop.enable=true;
  programs.bottom.enable=true;

  programs.jq.enable=true;


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
    git = "LANG=\"en_US.UTF-8\" git";
    ssh = "TERM=xterm-color ssh";
  };

  home.sessionVariables = {
    TERMINAL = "alacritty";
    TERM = "alacritty";
  };

  xdg.desktopEntries.calculator = {
    name = "Calculator";
    exec = "galculator";
    terminal = false;
    type = "Application";
    categories = ["System"];
  };
}
