{pkgs, config, ...} :
{

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history = {
      size = 10000;
      path = "${config.home.homeDirectory}/.zsh/history";
    };

    #initExtra = ''
    initContent = ''
    # sources bash extensions
    for file in ${config.home.homeDirectory}/.bashrc.d/*.bashrc; do
      source "$file"
      unset file
    done
    '';
  };

  programs.direnv.enableZshIntegration = true;

}