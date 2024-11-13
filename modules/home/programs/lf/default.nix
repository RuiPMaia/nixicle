{
  pkgs,
  config,
  lib,
  namespace,
  ...
}:
with lib; let
  cfg = config.${namespace}.programs.lf;
in {
  options.${namespace}.programs.lf = {
    enable = mkEnableOption "lf config";
  };

  config = mkIf cfg.enable {
    home = {
      # icons config file
      file."${config.xdg.configHome}/lf/icons".source = ./icons;
      # preview programs
      packages = with pkgs; [
        bat
        poppler_utils
        ueberzug
        sxiv
      ];
    };
    programs.lf = {
      enable = true;
       commands = {
         dragon-out = ''%${pkgs.xdragon}/bin/xdragon -a -x "$fx"'';
         editor-open = ''$$EDITOR $f'';
         mkdir = ''
         ''${{
           printf "Directory Name: "
           read DIR
           mkdir $DIR
         }}
          '';
       };
       keybindings = {
         "\\\"" = "";
         o = "";
         c = "mkdir";
         "." = "set hidden!";
         "`" = "mark-load";
         "\\'" = "mark-load";
         "<enter>" = "open";
       
         do = "dragon-out";
       
         "g~" = "cd";
         gh = "cd";
         "g/" = "/";
       };
       settings = {
         preview = true;
         hidden = true;
         drawbox = true;
         icons = true;
         ignorecase = true;
       };
       previewer = {
         keybinding = "i";
         source = "${pkgs.ctpv}/bin/ctpv";
       };
       extraConfig = ''
         &${pkgs.ctpv}/bin/ctpv -s $id
         cmd on-quit %${pkgs.ctpv}/bin/ctpv -e $id
         set cleaner ${pkgs.ctpv}/bin/ctpvclear
       '';
    };
  };
}
