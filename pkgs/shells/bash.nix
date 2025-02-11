{pkgs, ...} :
{

  programs.bash = {
    enable = true;
    enableCompletion = true;
    
    # home-manager settings
    historyControl = [ "ignoreboth" ];
    historyFile = "~/.bash_history";
    historyFileSize = 100000;
    historySize = 100000;
    
    shellOptions = [
      "cdspell"
      "checkwinsize"     #update shell to windows size
      "cmdhist"          #multi-line history
      "dotglob"
      "expand_aliases"
      "extglob"
      "histappend"
      "hostcomplete"
    ];

    shellAliases = {
      source_bash = "source ~/.bashrc";
      updateBash = "source ~/.bashrc";
    };

    bashrcExtra = ''
    # sources bash extensions
    for file in ~/.bashrc.d/*.bashrc; do
      source "$file"
      unset file
    done
    '';
  };

  
  programs.direnv.enableBashIntegration = true;

  # already enabled in configuration.nix
  services.gpg-agent.enableBashIntegration = true;
}