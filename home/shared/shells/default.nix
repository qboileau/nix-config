{config, lib, pkgs, ...} :
{
  imports = [
    ./bash.nix
    ./zsh.nix
  ];

  options = {
    terminal = {
      default = lib.mkOption {
        type = lib.types.enum [
          "alacritty"
          "ghostty"
        ];
        default = "ghostty";
        description = "Select the terminal emulator to use. Either alacritty or ghostty.";
      };
    };
  };

  config = {
    programs.alacritty = lib.mkIf (config.terminal.default == "alacritty") {
      enable = true;
      package = pkgs.unstable.alacritty;
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

    programs.ghostty = lib.mkIf (config.terminal.default == "ghostty") {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      settings = {
        font-family = "FiraCode Nerd Font Mono";
        font-size = 12;
        theme = "light:Adwaita,dark:Adwaita Dark";
        background = "black";
      };
    };

    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      # See https://starship.rs/config/
      settings = {
        add_newline = true;
        scan_timeout = 30;
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
  };
}