# Runs Claude Code inside a docker container (`cclaude`) instead of on the host:
# only $PWD and ~/.claude* are visible, env is an explicit allow-list, but the
# host /nix store and nix-daemon are shared so `nix shell` stays cheap.
{ config, lib, pkgs, osConfig, ... }:

let
  cfg = config.programs.cclaude;

  cclaudeImage = pkgs.dockerTools.buildLayeredImage {
    name = "cclaude";
    tag = "latest";
    contents = [ cfg.package pkgs.dockerTools.usrBinEnv ] ++ (with pkgs; [
      bashInteractive coreutils gnugrep gnused which findutils gnumake
      git cacert gnupg openssh curl wget
      ripgrep jq gh
      fd bat eza
      nodejs_22 python3 go cargo
      nix # talks to the host nix-daemon over its socket under the ro /nix mount
    ]);
    config = {
      Env = [
        "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
        "NIX_REMOTE=daemon"
        "NIX_CONFIG=experimental-features = nix-command flakes"
        "HOME=/home/claude"
        "PATH=/bin:/usr/bin"
      ];
      Entrypoint = [ "${cfg.package}/bin/claude" ];
      WorkingDir = "/workspace";
    };
    # The container runs as the host uid, which owns nothing in the image, so
    # $HOME has to be world-writable for claude to write its own state there.
    extraCommands = ''
      mkdir -p home/claude workspace tmp
      chmod -R 0777 home tmp workspace
    '';
  };

  # Match the host daemon's client rather than pulling in a second docker build.
  dockerPkg = osConfig.virtualisation.docker.package or pkgs.docker;

  cclaude = pkgs.writeShellApplication {
    name = "cclaude";
    runtimeInputs = [ dockerPkg ];
    text = ''
      HERE="$(pwd)"
      mkdir -p "$HOME/.claude"
      touch "$HOME/.claude.json"

      # nix and git resolve $HOME through getpwuid, so the host uid needs a
      # passwd entry; it is only known at runtime, hence generated here.
      NSS_DIR="''${XDG_RUNTIME_DIR:-/tmp}/cclaude"
      mkdir -p "$NSS_DIR"
      printf 'root:x:0:0:root:/root:/bin/bash\nclaude:x:%s:%s:claude:/home/claude:/bin/bash\n' \
        "$(id -u)" "$(id -g)" > "$NSS_DIR/passwd"
      printf 'root:x:0:\nclaude:x:%s:\n' "$(id -g)" > "$NSS_DIR/group"

      exec docker run --rm -it \
        --user "$(id -u):$(id -g)" \
        --network host \
        -v "$HERE:/workspace" \
        -v "$HOME/.claude:/home/claude/.claude" \
        -v "$HOME/.claude.json:/home/claude/.claude.json" \
        -v "$NSS_DIR/passwd:/etc/passwd:ro" \
        -v "$NSS_DIR/group:/etc/group:ro" \
        -v /nix:/nix:ro \
        -v /etc/nix/nix.conf:/etc/nix/nix.conf:ro \
        -v /etc/nix/registry.json:/etc/nix/registry.json:ro \
        -e CLAUDE_CODE_OAUTH_TOKEN \
        -e GITHUB_TOKEN \
        cclaude:latest "$@"
    '';
  };
in {
  options.programs.cclaude = {
    enable = lib.mkEnableOption "sandboxed Claude Code container (adds the `cclaude` command)";
    package = lib.mkPackageOption pkgs "claude-code" { };
  };

  config = lib.mkIf cfg.enable {
    # osConfig is only populated when home-manager runs as a NixOS module;
    # home-manager alone cannot enable the system docker service.
    assertions = [{
      assertion = osConfig.virtualisation.docker.enable or false;
      message = "programs.cclaude needs virtualisation.docker.enable = true in the NixOS config";
    }];

    home.packages = [ cclaude ];

    # No-op when the image content hash is unchanged since the last switch.
    home.activation.cclaudeImage = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD ${dockerPkg}/bin/docker load -i ${cclaudeImage} >/dev/null 2>&1 || true
    '';
  };
}
