# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'

pkgs: {
  openlens = pkgs.callPackage ./openlens { };
  hypr-i3-move = pkgs.callPackage ./hypr-i3-move { };
  helm-readme-generator = pkgs.callPackage ./helm-readme-generator { };
}