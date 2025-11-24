{config, pkgs, ...} :
{
    imports = [
      ./bash.nix
      ./zsh.nix
    ];

    programs.alacritty = {
      enable = true;
      # See https://alacritty.org/config-alacritty.html
      settings = {
        general = {
          live_config_reload = true;
        };
        colors = {
          draw_bold_text_with_bright_colors = true;
        };
        font = {
          size = 12;
        };
      };
    };

    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      # See https://starship.rs/config/
      settings = {
        add_newline = true;
        scan_timeout = 10;
        username = {
          show_always = true;
        };
        directory = {
          truncate_to_repo = true;
          truncation_length = 8;
        };
        git_commit = {
          commit_hash_length = 5;
        };
      };
    };

    home.file.bashFunctions = {
      enable = true;
      source =./cfg/functions.bashrc;
      target = ".bashrc.d/functions.bashrc";
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      config = {
        global = {
          load_dotenv = true;
        };
        whitelist = {
          prefix = [ 
            "${config.home.homeDirectory}/projects/perso"
            "${config.home.homeDirectory}/projects/work"
            "${config.home.homeDirectory}/projects/conduktor"
          ];
        };
      };
    };

}