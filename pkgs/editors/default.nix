{pkgs, ...} :
{
  imports = [
    ./fonts.nix
    ./vim.nix
    ./nano.nix
    ./xed.nix
    ./vscode.nix
    ./intellij.nix
  ];

  programs.vim.defaultEditor = true;
  
}