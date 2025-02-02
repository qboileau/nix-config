{pkgs, ...} :
{

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history = {
      size = 10000;
      path = "~/zsh/history";
    };

  };

  programs.direnv.enableZshIntegration = true;

}