{config, pkgs, ...} :
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
        path = "${config.home.homeDirectory}/.config/git/personal";
        condition = "gitdir:${config.home.homeDirectory}/.setup/";
      }
      {
        path = "${config.home.homeDirectory}/.config/git/personal";
        condition = "gitdir:${config.home.homeDirectory}/projects/perso/";
      }
      {
        path = "${config.home.homeDirectory}/.config/git/work";
        condition = "gitdir:${config.home.homeDirectory}/projects/work/";
      }
      {
        path = "${config.home.homeDirectory}/.config/git/conduktor";
        condition = "gitdir:${config.home.homeDirectory}/projects/conduktor/";
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
        helper = "store";
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

  xdg.configFile."git/personal".text = ''
  [user]
    name = Quentin Boileau
    username = qboileau
    email = quentin.boileau@gmail.com
    signingkey = 1EE3013384394A30
  
  [commit]
    gpgsign = true
  [tag]
    gpgsign = true

  [credential "https://github.com"]
    username = qboileau

  [credential "http://gitlab.com"]
    username = qboileau
  '';

  xdg.configFile."git/work".text = ''
  [user]
    name = Quentin Boileau
    username = qboileau
    # TODO
  '';

  home.file."projects/perso/.placeholder".text = "#placeholder";
  home.file."projects/work/.placeholder".text = "#placeholder";
  home.file."projects/conduktor/.placeholder".text = "#placeholder";
}

