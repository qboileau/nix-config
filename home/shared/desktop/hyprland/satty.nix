{config, pkgs, ...} :
{

  programs.satty = {
    enable = true;
    # https://github.com/Satty-org/Satty?tab=readme-ov-file#configuration-file
    settings = {
      general = {
        #fullscreen = true;
        corner-roundness = 1;
        initial-tool = "brush";
        output-filename = "${config.xdg.userDirs.pictures}/screenshot-%Y-%m-%d_%H:%M:%S.png";
      };
    };
  };
}