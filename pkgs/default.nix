# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
# Packaging helpers : https://nixos.org/manual/nixpkgs/stable/#chap-language-support

# Compute hash :
# For GitHub sources:
# nix-prefetch-github owner repo --rev tag
# OR nix-prefetch-url "<tag-zip-sources>" --unpack | xargs nix hash to-sri --type sha256

pkgs: {
  openlens = pkgs.callPackage ./openlens { };
  hypr-i3-move = pkgs.callPackage ./hypr-i3-move { };
  helm-readme-generator = pkgs.callPackage ./helm-readme-generator { };
  vscode-extension-4ops-terraform = pkgs.callPackage ./vscode-extension-4ops-terraform { };
  vscode-extension-carlocardella.vscode-texttoolbox = pkgs.callPackage ./vscode-extension-carlocardella.vscode-texttoolbox { };
  vscode-extension-buenon.scratchpads = pkgs.callPackage ./vscode-extension-buenon.scratchpads { };
  boucle-framework-hooks = pkgs.callPackage ./boucle-framework-hooks { };
}