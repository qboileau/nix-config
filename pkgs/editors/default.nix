{pkgs, ...} :
{
  imports = [
    ./fonts.nix
    ./vim.nix
    ./nano.nix
    ./vscode.nix
    ./intellij.nix
    ./zed.nix
    ./xed.nix
  ];

  programs.vim.defaultEditor = true;
  
}