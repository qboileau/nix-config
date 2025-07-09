# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'

pkgs: {
  import = [
      ./base-tools.nix
      ./work-tools.nix

      ./shells/default.nix
      ./dev/default.nix
      ./editors/default.nix
    ];
}
