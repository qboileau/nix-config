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

    initExtra = ''
    # sources bash extensions
    for file in ~/.bashrc.d/*.bashrc; do
      source "$file"
      unset file
    done
    '';
  };

  programs.direnv.enableZshIntegration = true;

}