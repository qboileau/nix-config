{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.editors;
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
    };
  };
}
