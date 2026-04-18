{pkgs, ...} :
{
  # Modern CLI replacement tools - always installed
  # Better alternatives to standard Unix utilities
  
  # Modern CLI replacements
  programs.bat.enable = true;      # better cat
  programs.eza.enable = true;      # better ls
  programs.ripgrep.enable = true;  # better grep
  programs.fd.enable = true;       # better find
  programs.tealdeer.enable = true; # TLDR
  programs.fzf.enable = true;      # Fuzzy finder
  programs.jq.enable = true;       # JSON processor
  
  home.packages = with pkgs; [
    duf  # better du / df
  ];

  # Shell aliases for the replacement tools
  home.shellAliases = {
    ls = "eza --group-directories-first --time-style=long-iso --git --color=auto -F --octal-permissions";
    ll = "eza -lah --group-directories-first --time-style=long-iso --git --color=auto -F --octal-permissions";
    tree = "eza -lah --group-directories-first --time-style=long-iso --git --color=auto --tree -F";
    grep = "rg";
    cp = "cp -i";  # confirm before overwriting
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
}
