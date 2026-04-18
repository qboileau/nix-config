{pkgs, config, lib, ...} :
let
  cfg = config.editors;
in {
  options = {
    editors.vim = {
      enable = lib.mkEnableOption "Vim text editor";
      defaultEditor = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Set Vim as the default editor";
      };
    };
  };

  config = lib.mkIf cfg.vim.enable {
    programs.vim = {
      enable = true;
      defaultEditor = cfg.vim.defaultEditor;
    plugins = with pkgs.vimPlugins; [ 
      vim-vagrant
    ];
    settings = { ignorecase = true; };
    extraConfig = ''
      set nocompatible
      set number
      set mouse=a

      filetype plugin indent on
      syntax on
    '';
    };
  };
}