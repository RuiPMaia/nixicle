{
  pkgs,
  config,
  lib,
  namespace,
  ...
}:
with lib; let
  cfg = config.${namespace}.desktop.dwm;
in {
  options.${namespace}.desktop.dwm = {
    enable = mkEnableOption "dwm window manager";
  };

  config = mkIf cfg.enable {
    xsession = let 
      xkb-layout = pkgs.writeText "xkb-layout" ''
        clear lock
        clear control
        clear mod1
        clear mod2
        clear mod3
        clear mod4
        clear mod5
        keycode 66 = Control_L
        keycode 37 = Meta_L
        keycode 64 = Alt_L
        keycode 135 = Multi_key
        add control = Control_L Control_R
        add mod1 = Alt_L
        add mod2 = Super_L
        add mod3 = Hyper_L
        add mod4 = Meta_L
        add mod5 = Mode_switch
      '';
    in {
      enable = true;
      windowManager.command = "ssh-agent dwm";
      initExtra = ''
        setbg &
        xmodmap ${xkb-layout}
      '';
      profilePath = ".config/x11/profile";
      scriptPath = ".config/x11/session";
  };
  };
}
