{pkgs, ...} :
{

  home.packages = with pkgs; [ 
    meld
    git-interactive-rebase-tool
    gnupg
  ];

  programs.git = {
    enable = true;
    userName = "Quentin Boileau";
    aliases = {
      fall = "fetch -a";
      pr = "pull --rebase";
      co = "checkout";
      cotrack = "checkout --track";
      ci = "commit";
      st = "status";
      br = "branch";
      save = "stash";
      load = "stash pop";
      hist = "log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short";
      ll = "log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short";
    };

    diff-so-fancy.enable = true;
    diff-so-fancy.pagerOpts = [ "--tabs=4" "-RFX"];


    includes = [
      {
        path = "~/.gitconfig-personal";
        condition = "gitdir:~/projects/perso/";
      }
      {
        path = "~/.gitconfig-work";
        condition = "gitdir:~/projects/work/";
      }
    ];

    extraConfig = {
      core = {
        autocrlf = "input";
      };
      init = {
        defaultBranch = "main";
      };
      push = {
        default = "simple";
      };
      merge = {
        tool = "meld";
      };
      sequence = {
        editor = "interactive-rebase-tool";
      };
      credential = {
        helper = "cache --timeout=3600";
      };
      program = { 
        pgp = "gpg";
      };
      color = {
          status = "always";
          diff = "always";
          branch = "always";
      };
    };
  };

  home.file.".gitconfig-personal".text = ''
  [user]
    name = Quentin Boileau
    username = qboileau
    email = quentin.boileau@gmail.com

  [credential "https://github.com"]
    username = qboileau

  [credential "http://gitlab.com"]
    username = qboileau
  '';

  home.file.".gitconfig-work".text = ''
  [user]
    name = Quentin Boileau
    username = qboileau
    # TODO
  '';
}