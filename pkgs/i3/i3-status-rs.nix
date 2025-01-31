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
            format = "$icon {$combo.str(max_w:25,rot_interval:0.5) $prev $play $next |}";
          }
          {
            block = "memory";
            format = " $icon $mem_used.eng(prefix:Mi)/$mem_total.eng(prefix:Mi)($mem_avail_percents.eng(w:2))";
            #display_type = "memory";
            #format_mem = " $icon $mem_used_percents ";
            #format_swap = " $icon $swap_used_percents ";
            
            # format_mem = "{mem_total_used;G} {mem_used_percents}";
            # format_swap = "{swap_used;G} {swap_used_percents}";
          }
          {
            block = "net";
            primary_only = true;
            block = "networkmanager";
            on_click = "nm-connection-editor";
          }
          {
            block = "cpu";
            interval = 1;
            format = "$barchart $utilization $frequency";
          }
          {
            block = "battery";
            interval = 10;
            format = "{percentage} {time}";
          }
          {
            block = "keyboard_layout";
            driver = "setxkbmap";
            interval = 60;
          }
          # { block = "sound"; }
          {
            block = "time";
            interval = 60;
            format = "$timestamp.datetime(f:'%R')";
            timezone = "Europe/Paris";
            on_click = "toggle_gsimplecal";
          }
          {
            block = "time";
            interval = 60;
            format = "$icon $timestamp.datetime(f:'%Y %d/%m')";
            timezone = "Europe/Paris";
            on_click = "toggle_gsimplecal";
          }
        ];
        icons = "awesome5";
        theme = "modern";
      };
    };
  };


}