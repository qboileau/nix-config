{ lib, buildGoModule, fetchFromGitHub, stdenv, }:
buildGoModule rec {
  pname = "hypr-i3-move";
  version = "0.1";
  src = ./.;
  vendorHash = null;
  meta = {
    description = "A Go application to manage Hyprland window focus";
    homepage = "https://github.com/qboileau/nix-config/pkgs/hyprland/hypr-i3-move";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ "qboileau" ];
  };
}