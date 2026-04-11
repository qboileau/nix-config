{config, pkgs, ...} :
{

  home.packages = with pkgs; [ 
    meld
    git-interactive-rebase-tool
    gnupg
  ];

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
       user.name = "Quentin Boileau";
       alias = {
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
        helper = "libsecret";
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
  };

  programs.diff-so-fancy.enable = true;
  programs.diff-so-fancy.enableGitIntegration = true;
  programs.diff-so-fancy.pagerOpts = [ "--tabs=4" "-RFX"];

  # Git identity configs are managed by agenix (encrypted secrets)
  # They are decrypted at activation to ~/.config/git/personal, work, conduktor

  # xdg.configFile."git/work".text = ''
  # [user]
  #   name = Quentin Boileau
  #   username = qboileau
  #   # TODO
  # '';

  home.file."projects/perso/.placeholder".text = "#placeholder";
  home.file."projects/work/.placeholder".text = "#placeholder";
  home.file."projects/conduktor/.placeholder".text = "#placeholder";
}
