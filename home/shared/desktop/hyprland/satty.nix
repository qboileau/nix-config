{config, pkgs, inputs, ...} :
{

  
  programs.satty.enable = {
    enable = true;
    settings = {
      general = {
        #fullscreen = true;
        corner-roundness = 1;
        initial-tool = "brush";
        output-filename = "/tmp/screenshot-%Y-%m-%d_%H:%M:%S.png";
      };
      color-palette = {
        palette = [ "#00ffff" "#a52a2a" "#dc143c" "#ff1493" "#ffd700" "#008000" ];
      };
    };
  };


}