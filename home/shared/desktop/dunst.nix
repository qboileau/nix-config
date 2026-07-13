{pkgs, ...} :
{

  services.dunst.enable=true;
  services.dunst.settings = {
    global = {
      width = 300;
      height = 300;
      line_height = 0;
      separator_height = 1;
      padding = 8;
      horizontal_padding = 10;
      separator_color = "#454947";
      alignment = "left";
      offset = "30x50";
      origin = "top-right";
      transparency = 15;
      show_age_threshold = 60;
      # [frame] section is deprecated in modern dunst; frame options live in global.
      frame_width = 1;
      frame_color = "#eceff1";
      font = "Droid Sans 9";
      icon_position = "left";
      max_icon_size = 80;
      idle_threshold = 120;
      follow = "mouse";
      sticky_history = "yes";
      history_length = 20;
      show_indicators = "yes";
      markup = "full";
      browser = "brave";
      # Escaped \n so the generated dunstrc keeps a literal "\n" on one line;
      # an unescaped newline splits the value across two lines and dunst rejects it.
      format = "%s %p\\n%b";
      word_wrap = "no";
      ignore_newline = "no";
      sort = "yes";
      indicate_hidden = "yes";
    };

    urgency_low = {
      background = "#2B2C2B";
      foreground = "#888888";
      timeout = 10;
    };

    urgency_normal = {
      background = "#2B2C2B";
      foreground = "#F9FAF9";
      timeout = 10;
    };
    urgency_critical = {
      background = "#D62929";
      foreground = "#F9FAF9";
      timeout = 0;
    };
  };
}