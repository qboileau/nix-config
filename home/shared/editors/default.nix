{pkgs, ...} :
{
  imports = [
    ./fonts.nix
    ./vim.nix
    ./vscode.nix
    ./intellij.nix
    ./zed.nix
    ./xed.nix
  ];

  programs.vim.defaultEditor = true;
  
}