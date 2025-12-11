{ pkgs, inputs, config, lib, username, ... }:
{
  imports = [
    ./options.nix
  ];

  #https://docs.noctalia.dev/
  config = lib.mkIf config.noctalia.enable {
    environment.systemPackages = with pkgs; [
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    
    # Home manager
    home-manager.users.${username} = {
      programs.noctalia-shell = {
      enable = true;
      # https://docs.noctalia.dev/getting-started/nixos/#config-ref
      settings = {
        bar = {
          density = "compact";
          position = "bottom";
          showCapsule = false;
          widgets = {
            left = [
              {
                id = "Workspace";
                hideUnoccupied = false;
              }
            ];
            center = [
              {
                id = "ActiveWindow";
              }
            ];
            right = [
              {
                id = "MediaMini";
              }
              {
                id = "Volume";
              }
              {
                id = "WiFi";
              }
              {
                id = "Bluetooth";
              }
              {
                formatHorizontal = "HH:mm";
                formatVertical = "HH mm";
                id = "Clock";
                useMonospacedFont = true;
                usePrimaryColor = true;
              }             
              {
                id = "Tray";
              }
              {
                id = "ControlCenter";
                useDistroLogo = true;
              }
            ];
          };
        };
        colorSchemes.predefinedScheme = "Monochrome";
        general = {
        };
          ui = {
          fontDefault = "";
          fontFixed = "";
          fontDefaultScale = 1;
          fontFixedScale = 1;
          tooltipsEnabled = true;
          panelBackgroundOpacity = 1;
          panelsAttachedToBar = true;
          settingsPanelAttachToBar = false;
        };
        location = {
          monthBeforeDay = true;
          name = "Montpellier, France";
        };
        wallpaper = {
          enabled = false;
        };
      };
      # this may also be a string or a path to a JSON file,
      # but in this case must include *all* settings.
    };
  };
  };
}