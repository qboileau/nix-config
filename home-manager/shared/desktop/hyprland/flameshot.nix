{config, pkgs, inputs, ...} :
{

  services.flameshot = {
    enable = true;
    package = pkgs.unstable.flameshot; #.override { enableWlrSupport = true; };
    settings = {
      # https://github.com/flameshot-org/flameshot/blob/master/flameshot.example.ini
      General = {
        #useGrimAdapter = true; # use grim for screenshots
        contrastOpacity = 188;
      };
    };
  };


}