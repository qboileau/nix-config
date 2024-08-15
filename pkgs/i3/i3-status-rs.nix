{pkgs, ...} :
{
  
  # extra package needed
  home.packages = with pkgs; [ 
    texlivePackages.fontawesome5
    networkmanagerapplet
    gsimplecal
  ];

  programs.i3status-rust = {
    enable = true;
    bars = {
      bottom = {
        blocks = [
          {
            block = "music";
            player = "spotify";
            buttons = ["play" "next"];
            #max_width = 20;
          }
          {
            block = "memory";
            display_type = "memory";
            format_mem = " $icon $mem_used_percents ";
            format_swap = " $icon $swap_used_percents ";
            
            # format_mem = "{mem_total_used;G} {mem_used_percents}";
            # format_swap = "{swap_used;G} {swap_used_percents}";
          }
          {
            block = "networkmanager";
            primary_only = true;
            on_click = "nm-connection-editor";
          }
          {
            block = "cpu";
            interval = 1;
            format = "{barchart} {utilization} {frequency}";
          }
          {
            block = "battery";
            interval = 10;
            format = "{percentage} {time}";
          }
          {
            block = "keyboard_layout";
            driver = "setxkbmap";
            interval = 15;
          }
          # { block = "sound"; }
          {
            block = "time";
            interval = 60;
            format = "%a %d/%m %R";
            on_click = "toggle_gsimplecal";
          }
        ];
        icons = "awesome5";
        theme = "modern";
      };
    };
  };


}