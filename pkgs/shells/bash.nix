{pkgs, ...} :
{

  programs.bash = {
    enable = true;
    enableCompletion = true;
    
    # home-manager settings
    historyControl = "ignoreboth";
    historyFile = "${config.xdg.dataHome}/.bash/history";
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
  };
  
  environment.pathsToLink = [ "/share/bash-completion" ];
  
  programs.direnv.enableBashIntegration = true;

  programs.bash.shellAliases = {
    source_bash = "source ~/.bashrc";
    updateBash = "source ~/.bashrc";
  };
}