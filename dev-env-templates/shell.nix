
# using nix shell
# run nix-shell (shell.nix)
# with direnv also add .envrc with "use nix" inside
# To get all version available : nix-env -qP --available <package>

let
  unstableTarball = fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
  pkgs = import <nixpkgs> {};
  unstable = import unstableTarball {};

  shell = pkgs.mkShell {
    buildInputs = [
       unstable.terraform
       pkgs.rustup
     ];
  };
in shell