{pkgs, ...} :
{

  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [ 
      vimPlugins.vim-vagrant
    ];
    settings = { ignorecase = true; };
    extraConfig = ''
      set nocompatible
      set number
      set mouse=a

      " Initialisation de pathogen
      call pathogen#infect()
      call pathogen#helptags()

      filetype plugin indent on
      syntax on
    '';
  };

}