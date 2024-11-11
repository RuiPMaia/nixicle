{
  config,
  lib,
  namespace,
  ...
}:
with lib; let
  cfg = config.${namespace}.programs.zathura;
in {
  options.${namespace}.programs.zathura = {
    enable = mkEnableOption "zathura config";
  };

  config = mkIf cfg.enable {
    programs.zathura = {
      enable = true;
      options = {
        sandbox = "none";
        statusbar-h-padding = 0;
        statusbar-v-padding = 0;
        page-padding = 1;
        adjust-open = "best-fit";
        selection-clipboard = "clipboard";
        recolor-lightcolor = "#222221";
        recolor-keephue = true;
        default-bg = "#222230";
      };
      mappings = {
        u = "scroll half-up";
        d = "scroll half-down";
        D = "toggle_page_mode";
        r = "reload";
        R = "rotate";
        K = "zoom in";
        J = "zoom out";
        i = "recolor";
        p = "print";
        g = "goto top";
      };
    };
  };
}
