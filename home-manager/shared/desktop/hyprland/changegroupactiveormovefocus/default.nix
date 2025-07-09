# { pkgs, lib, ... }:
# {
#   # pkgs.buildGoModule = {
#   #   pname = "changegroupactiveormovefocus";
#   #   version = "0.1";
#   #   src = ./.; # Path to your Go module
#   #   vendorSha256 = "0000000000000000000000000000000000000000000000000000"; # Replace with the actual sha256 hash of your dependencies
#   #   modules = [ ./go.mod ]; # Path to your go.mod file
#   #   subPackages = [ "changegroupactiveormovefocus" ]; # Replace with your actual module name
#   #   meta = with pkgs.lib; {
#   #     description = "A Go application to manage Hyprland window focus";
#   #     homepage = "https://github.com/qboileau/changegroupactiveormovefocus";
#   #     license = licenses.mit;
#   #     maintainers = with maintainers; [ "qboileau" ];
#   #   };
#   # };

  
#   pkgs.buildGoModule (finalAttrs: {
#     pname = "changegroupactiveormovefocus";
#     version = "0.1";
#     src = ./.;
#     sourceRoot = ".";
#     vendorHash = null;
#     meta = {
#       description = "A Go application to manage Hyprland window focus";
#       homepage = "https://github.com/qboileau/nix-config/pkgs/hyprland/changegroupactiveormovefocus";
#       license = lib.licenses.mit;
#       maintainers = with lib.maintainers; [ "qboileau" ];
#     };
#   });

# }


{ lib, buildGoModule, fetchFromGitHub, stdenv, }:
buildGoModule rec {
  pname = "changegroupactiveormovefocus";
  version = "0.1";
  src = ./.;
  vendorHash = null;
  meta = {
    description = "A Go application to manage Hyprland window focus";
    homepage = "https://github.com/qboileau/nix-config/pkgs/hyprland/changegroupactiveormovefocus";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ "qboileau" ];
  };
}