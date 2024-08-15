
# using nix shell
# run nix-shell (shell.nix)
# with direnv also add .envrc with "use nix" inside
# To get all version available : nix-env -qP --available <package>
{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    nativeBuildInputs = with pkgs.buildPackages; [ 
      ruby_3_2 
      jdk11
      nodejs
      python313
      ansible
      terraform
    ];
}