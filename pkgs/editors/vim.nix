{pkgs, ...} :
{

  programs.vim = {
    enable = true;
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

}