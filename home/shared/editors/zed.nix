{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.editors;

  # Wrapper around the @agentclientprotocol/claude-agent-acp npm package.
  # Zed's bundled Node unpacks the tarball without preserving the executable
  # bit on dist/index.js, causing "exit status 126: Permission denied" when
  # the registry-managed binary is launched. Running via the system npx writes
  # to ~/.npm/_npx where npm preserves perms correctly.
  claude-agent-acp = pkgs.writeShellApplication {
    name = "claude-agent-acp";
    runtimeInputs = [ pkgs.nodejs ];
    text = ''
      exec npx --yes @agentclientprotocol/claude-agent-acp "$@"
    '';
  };
in
{
  options = {
    editors.zed = {
      enable = lib.mkEnableOption "Zed editor";
    };
  };

  config = lib.mkIf cfg.zed.enable {
    programs.zed-editor = {
      enable = true;
      package = pkgs.unstable.zed-editor;
      installRemoteServer = false;
      extraPackages = [ claude-agent-acp ];
      extensions = [
        "make"
        "toml"
        "nix"
        "agnix"
        "java"
        "kotlin"
        "scala"
        "terraform"
        "dockerfile"
        "docker-compose"
        "helm"
        "claude-acp"
      ];
      userSettings = {
        agent_servers."claude-acp" = {
          command = "claude-agent-acp";
          args = [ ];
        };
      };
    };
  };
}
