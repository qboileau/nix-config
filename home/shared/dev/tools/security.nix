{pkgs, config, lib, ...} :
let
  cfg = config.dev.tools;
in {
  options = {
    dev.tools.security = {
      enable = lib.mkEnableOption "Security and CVE scanning tools";
    };
  };

  config = lib.mkIf cfg.security.enable {
    home.packages = with pkgs; [
      # Nix-native CVE scanner: walks a derivation closure and cross-references NVD.
      # Usage:
      #   vulnix --system                             # scan full system closure
      #   vulnix --closure $(nix build .#free-claude-code --no-link --print-out-paths)
      vulnix

      # Multi-target scanner with Nix support (filesystem, containers, SBOM).
      # Usage:
      #   trivy fs --scanners vuln /nix/store/<hash>-free-claude-code
      #   trivy fs --scanners vuln .         # scan this flake's lockfile
      unstable.trivy

      # SBOM generator — produces a machine-readable inventory of a store path
      # that can be fed to grype or uploaded to a tracking platform.
      # Usage:
      #   syft /nix/store/<hash>-free-claude-code -o spdx-json > sbom.json
      unstable.syft
    ];
  };
}
