{
  config,
  lib,
  namespace,
  ...
}:
with lib; let
  cfg = config.${namespace}.services.dunst;
in {
  options.${namespace}.services.dunst = {
    enable = mkEnableOption "dunst service";
  };

  config = mkIf cfg.enable {
    services.dunst = {
      enable = true;
      settings = {
        global = {
          monitor = 0;
          follow = "keyboard";
          width = 370;
          height = 350;
          offset = "0x19";
          padding = 2;
          horizontal_padding = 2;
          transparency = 25;
          font = "Monospace 12";
          format = "<b>%s</b>\\n%b";
        };
        urgency_low = {
          background = "#1d2021";
          foreground = "#928374";
          timeout = 3;
        };
        urgency_normal = {
          foreground = "#ebdbb2";
          background = "#458588";
          timeout = 5;
        };
        urgency_critical = {
          background = "#1cc24d";
          foreground = "#ebdbb2";
          frame_color = "#fabd2f";
          timeout = 10;
        };
      };
    };
  };
}