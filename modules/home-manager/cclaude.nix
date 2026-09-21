# Runs Claude Code inside a docker container (`cclaude`) instead of on the host:
# only $PWD is writable, the claude config is shared read-only while the
# session state and the login stay in the box, the env is an explicit
# allow-list and the network is a
# plain bridge (`cclaude --net host` opts back into the host loopback). The
# host /nix store and nix-daemon are shared so `nix shell` stays cheap — note
# that the daemon is a privileged socket, even though this client is untrusted.
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
      # `cclaude --net host` re-exposes the host loopback (kubectl port-forwards,
      # ollama, ...) to the container; the default bridge keeps it out.
      NET=bridge
      if [ "''${1:-}" = "--net" ]; then
        NET="$2"
        shift 2
      fi

      HERE="$(pwd)"

      # cclaude_<workdir>_<random>: the suffix keeps concurrent boxes in the
      # same directory from colliding. Docker names allow [a-zA-Z0-9_.-] only,
      # and the constant prefix covers the must-be-alphanumeric first char.
      SUFFIX_CHARS=abcdefghijklmnopqrstuvwxyz0123456789
      SUFFIX=""
      for _ in 1 2 3 4 5; do
        SUFFIX+="''${SUFFIX_CHARS:RANDOM%''${#SUFFIX_CHARS}:1}"
      done
      NAME="''${HERE##*/}"
      NAME="cclaude_''${NAME//[^a-zA-Z0-9_.-]/_}_$SUFFIX"

      # The box keeps its own claude state: the host ~/.claude holds every past
      # session transcript, and is writable enough to plant hooks that the
      # *host* claude would then run.
      # Mounted as the whole container $HOME: claude rewrites ~/.claude.json by
      # rename, which is EBUSY against a bind-mounted *file* but fine inside a
      # bind-mounted directory. It is seeded rather than touch'd because claude
      # parses it at startup and an empty file is a JSON error.
      STATE="''${XDG_DATA_HOME:-$HOME/.local/share}/cclaude"
      mkdir -p "$STATE/.claude"
      [ -s "$STATE/.claude.json" ] || echo '{}' > "$STATE/.claude.json"

      # Config is still shared from the host, so the box behaves like the host
      # claude. Mountpoints are pre-created, otherwise docker makes them
      # root-owned inside $STATE.
      shared=()
      add_share() { # <name in ~/.claude> [mount options]
        local src="$HOME/.claude/$1"
        [ -e "$src" ] || return 0
        if [ ! -e "$STATE/.claude/$1" ]; then
          if [ -d "$src" ]; then mkdir -p "$STATE/.claude/$1"; else touch "$STATE/.claude/$1"; fi
        fi
        shared+=(-v "$src:/home/claude/.claude/$1''${2:+:$2}")
      }
      for f in CLAUDE.md settings.json skills; do add_share "$f" ro; done

      # Credentials are deliberately *not* shared: they are the one piece of
      # config claude has to write back (the login flow, and every OAuth
      # refresh afterwards), so a ro mount silently loses the session. Sharing
      # them writable would instead let the box rotate the refresh token out
      # from under the host claude. So the box logs in once, on its own.
      if [ -z "''${CLAUDE_CODE_OAUTH_TOKEN:-}" ] && [ ! -s "$STATE/.claude/.credentials.json" ]; then
        echo "[cclaude] the box logs in separately from the host; its state lives in $STATE" >&2
      fi

      # nix and git resolve $HOME through getpwuid, so the host uid needs a
      # passwd entry; it is only known at runtime, hence generated here.
      NSS_DIR="''${XDG_RUNTIME_DIR:-/tmp}/cclaude"
      mkdir -p "$NSS_DIR"
      printf 'root:x:0:0:root:/root:/bin/bash\nclaude:x:%s:%s:claude:/home/claude:/bin/bash\n' \
        "$(id -u)" "$(id -g)" > "$NSS_DIR/passwd"
      printf 'root:x:0:\nclaude:x:%s:\n' "$(id -g)" > "$NSS_DIR/group"

      exec docker run --rm -it \
        --name "$NAME" \
        --user "$(id -u):$(id -g)" \
        --network "$NET" \
        --security-opt no-new-privileges \
        --cap-drop ALL \
        --pids-limit 2048 \
        -v "$HERE:/workspace" \
        -v "$STATE:/home/claude" \
        "''${shared[@]}" \
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
