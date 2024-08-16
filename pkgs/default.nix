# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...} :
{
    import = [
      ./shells
      ./base-tools.nix

      # ./dev
      # ./editors
      # ./i3/i3-config.nix
    ];
}
