{...} :
{
  # Text editors with granular options
  # Fonts are always imported as they're shared
  
  imports = [
    ./fonts.nix
    ./vim.nix
    ./neovim.nix
    ./vscode.nix
    ./intellij.nix
    ./zed.nix
    ./xed.nix
  ];
}